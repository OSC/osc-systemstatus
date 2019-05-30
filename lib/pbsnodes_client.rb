# Utility class for getting numerical data from pbsnodes
#
# @author Kinan AlAttar
require 'open3'

class PBSNodesClient

    attr_accessor :gpus_used, :gpus_available

    # Set the object to the server.
    #
    # @param [OodAppkit::Cluster]
    #
    # @return [PBSNodesClient] self
    def initialize(cluster)
     @server = cluster.custom_config[:pbs]
     @cluster_id = cluster.id
     @cluster_title = cluster.metadata.title || cluster.id.titleize
     self
    end

    def setup
      self.gpus_available = calc_available_gpus
      self.gpus_used = calc_gpus_used
      self
    rescue => e
        PBSNodesClientNotAvailable.new(cluster_id, cluster_title, e)
    end

    def pbs_bin
      Pathname.new(@server['bin'].to_s)
    end

    # Defines a method for counting values of gpu_state
    #
    # @param[first_cmd_arg]
    def gpu_states(first_cmd_arg)
        cmd = pbs_bin.join("pbsnodes").to_s
        args = ["-s", first_cmd_arg , ":gpu"]
        o, e, s = Open3.capture3(cmd, *args)
        s.success? ? o.scan(/gpu_state=(\w+)/) : raise(CommandFailed, e)
    rescue Errno::ENOENT => e
       raise InvalidCommand, e.message
    end

    # Defines a method for counting values of documented_threads
    #
    # @param[first_cmd_arg]
    def dedicated_threads(first_cmd_arg)
        cmd = pbs_bin.join("pbsnodes").to_s
        args = ["-s", first_cmd_arg , ":gpu"]
        o, e, s = Open3.capture3(cmd, *args)
        s.success? ? o.scan(/dedicated_threads = ../) : raise(CommandFailed, e)
    rescue Errno::ENOENT => e
      raise InvalidCommand, e.message
    end


    # Count available number of GPUs on a cluster
    def calc_available_gpus
       gpu_states(@cluster_title + "-batch.ten.osc.edu").size
    end

    # Count number of GPUs used
    def calc_gpus_used
      if @cluster_title != "Pitzer"
          gpu_states(@cluster_title + "-batch.ten.osc.edu").select {|state| state.include?("Unallocated")}.size
      else
          dedicated_threads(@cluster_title + "-batch.ten.osc.edu").select {|thread| thread.include?("40")}.size +
          gpu_states(@cluster_title + "-batch.ten.osc.edu").select {|state| state.include?("Unallocated")}.size
      end
    end

    # Return the GPUs used as percent of available GPUs
    #
    # @return [Float] The percentage GPUs used as float
    def gpus_percent
        (gpus_used.to_f / gpus_available.to_f) * 100
    end
end