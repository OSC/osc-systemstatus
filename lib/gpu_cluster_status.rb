# Utility class for getting numerical data regarding GPU usage in the set of clusters that allow job submission using pbsnodes & info_all
#
# @author Kinan AlAttar

class GPUClusterStatus

    attr_reader :gpus_unallocated, :total_gpus, :queued_gpus, :full_nodes_available, :queued_jobs_req_gpus, :error_message

    # Set the object to the server.
    #
    # @param cluster [OodAppkit::Cluster]
    #
    # @return [GPUClusterStatus]
    def initialize(cluster)
     config = YAML.load_file("/etc/ood/config/clusters.d/" + cluster.metadata.title.downcase + ".yml")
     @oodClustersAdapter = OodCore::Job::Factory.build(config.dig("v2","job") || config)
     @server = cluster.custom_config[:pbs]
     @cluster_id = cluster.id
     @cluster_title = cluster.metadata.title || cluster.id.titleize
     self
    end

    def setup
      @queued_jobs_req_gpus = @queued_gpus = 0
      calc_total_gpus
      calc_gpus_unallocated
      calc_full_nodes_avail
      calc_queued_jobs_and_gpus
      self
    rescue => e
      GPUClusterStatusNotAvailable.new(cluster_id, cluster_title, e)
    end

    # @return [Pathname] pbs bin pathname
    def pbs_bin
      Pathname.new(@server['bin'].to_s)
    end

    # Defines a method for writing a pbsnodes command line to a terminal.
    #
    # @param cluster_server [String]
    def pbsnodes(cluster_server)
        cmd = pbs_bin.join("pbsnodes").to_s
        args = ["-s", cluster_server, ":gpu"]
        o, e, s = Open3.capture3(cmd, *args)
        s.success? ? o : raise(CommandFailed, e)
    rescue Errno::ENOENT => e
       raise InvalidCommand, e.message
    end

    # @return [String] Information regarding cluster nodes
    def nodes_info
      pbsnodes(@cluster_title.downcase + "-batch.ten.osc.edu")
    end

    # Calculate total number of GPUs on a cluster
    # @return [Integer] total number of gpus in a cluster
    def calc_total_gpus
      if @cluster_title.eql?("Ruby")
         # For the Ruby cluster, pbsnodes takes into account two debug nodes with two GPUs along with the other Ruby GPU nodes. The debug nodes will not be considered in the total GPUs and unallocated GPUs calculation, as they cannot be allocated as part of a regular job request with other GPU nodes. Here np = 20 is the number of processors for a GPU node rather than a debug node (np = 16) in a Ruby cluster.
         @total_gpus = nodes_info.scan(/np = 20/).size
        else
         @total_gpus = nodes_info.lines("\n\n").size
      end
    end

    # Calculate number of unallocated GPUs with atleast one core available
    # @return [Integer] the number of unallocated GPUs
    def calc_gpus_unallocated
      if @cluster_title.eql?('Owens')
        @gpus_unallocated = nodes_info.lines("\n\n").select { |node|
          !node.include?("dedicated_threads = 28") && node.include?("Unallocated") }.size
       elsif @cluster_title.eql?('Pitzer')
        @gpus_unallocated = nodes_info.lines("\n\n").select { |node| !node.include?("dedicated_threads = 40") }.to_s.scan(/gpu_state=Unallocated/).size
       else @cluster_title.eql?('Ruby')
        # See line 62. Excluding the two debug nodes from the calculation.
        @gpus_unallocated = nodes_info.lines("\n\n").select { |node| node.include?("Unallocated") && !node.include?("dedicated_threads = 20") && node.include?("np = 20") }.size
        @oodClustersAdapter.info_all().each { |job| p job}
      end
    end

    # Calculate number of full nodes (nodes with all cores free) available that contain one or more GPUs available
    # @return [Integer] the number of full nodes available
    def calc_full_nodes_avail
      if @cluster_title.eql?("Ruby")
        # See line 62
      @full_nodes_available = nodes_info.lines("\n\n").select { |node| node.include?("dedicated_threads = 0") && node.include?("np = 20") && node.include?("gpu_state=Unallocated")}.size
      else
      @full_nodes_available = nodes_info.lines("\n\n").select { |node| node.include?("dedicated_threads = 0") && node.include?("gpu_state=Unallocated") }.size
      end
    end

    # Calculates number of jobs that have requested one or more GPUs that are currently queued
    # @return [Integer] the number of queued jobs requesting GPUs
    def calc_queued_jobs_and_gpus
      @queued_jobs_req_gpus = @queued_gpus = 0
      @oodClustersAdapter.info_all().each { |job| queued_jobs_req_gpus_counter(job) }
      @queued_jobs_req_gpus
    end

    # Checks to see whether a job is queued and requesting a gpu
    #
    # @param job [OodCore::Job::Info]
    # @return true if job requested a gpu and is queued otherwise false
    def is_job_req_gpus_and_queued(job)
      job.status.queued? && job.native[:Resource_List][:nodes].include?("gpus")
    end

    # Return the allocated GPUs as percent of available GPUs
    #
    # @return [Float] The percentage GPUs used
    def gpus_percent
      ((total_gpus - full_nodes_available).to_f / total_gpus.to_f) * 100
    end

    # Return the queued GPUs as percent of available GPUs
    #
    # @return [Float] The percentage GPUs queued
    def gpus_queued_percent
      (queued_gpus.to_f / total_gpus.to_f) * 100
    end

    private

      attr_accessor :oodClustersAdapter

    # Helper Methods

      # Helper method for counting the number of queued gpus and jobs requesting gpus
      #
      # @param job [OodCore::Job::Info]
      def queued_jobs_req_gpus_counter(job)
        if is_job_req_gpus_and_queued(job)
         @queued_jobs_req_gpus += 1
         @queued_gpus += job.native[:Resource_List][:nodes].slice(/gpus=(\d+)/).reverse.to_i
        end
      end
end
