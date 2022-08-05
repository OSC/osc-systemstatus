class SlurmSqueueClient

  attr_reader :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail, :error_message, :dashboard_url, :cluster_id, :cluster_title, :friendly_error_message

  # Set the object to the server.
  #
  # @param [OodAppkit::Cluster]
  #
  # @return [SlurmSqueueClient] self
  def initialize(cluster)
    @bin = cluster.job_config[:bin]
  
    if cluster.custom_config.key?(:grafana)
      @dashboard_url = "/clusters/#{cluster.id}/grafana"
    elsif cluster.custom_config.key?(:ganglia)
      @dashboard_url = "/clusters/#{cluster.id}/hour/report_moab_nodes"
    end
  
    @cluster_id = cluster.id
    @canonical_cluster_id = cluster.id
    @cluster_title = cluster.metadata.title || cluster.id.titleize
    @job_scheduler = cluster.job_config[:adapter]

    self
  end

  # Define path to squeue command
  def squeue_cmd
    File.join(@bin, 'squeue')
  end

  # Define path to sinfo command
  def sinfo_cmd
    File.join(@bin, 'sinfo')
  end

  # Define command line arguments used to filter results from SLURM, this
  # is passed to sinfo and squeue commands.
  #
  # @return [String] command line flags
  def cluster_args
    return @cluster_args if defined?(@cluster_args)

    @cluster_args ||= "--clusters=#{@canonical_cluster_id}"
  end

  # Return job scheduler type from config
  def job_scheduler_name
    @job_scheduler
  end

  # Get pending jobs
  def squeue_jobs_pending
    return @squeue_jobs_pending if defined?(@squeue_jobs_pending)

    args = ["-h", "--all", "--states=PENDING"]
    args.push(cluster_args)

    o, e, s = Open3.capture3({}, squeue_cmd, *args)
    
    s.success? ? @squeue_jobs_pending = o : raise(CommandFailed, e)
  end

  # Get running jobs
  def squeue_jobs_running
    return @squeue_jobs_running if defined?(@squeue_jobs_running)

    args = ["-h", "--all", "--states=RUNNING"]
    args.push(cluster_args)

    o, e, s = Open3.capture3({}, squeue_cmd, *args)
    
    s.success? ? @squeue_jobs_running = o : raise(CommandFailed, e)
  end

  # Get cluster info (node count, core count, etc.)
  def sinfo
    return @sinfo if defined?(@sinfo)

    args = ["-a", "-h", "-o=\"%C/%A/%D\""]
    args.push(cluster_args)

    o, e, s = Open3.capture3({}, sinfo_cmd, *args)
    
    s.success? ? @sinfo = o : raise(CommandFailed, e)
  end

  # Return length of GRES field from SLURM
  # @return [Integer] gres length
  def gres_length
    return @gres_length if defined?(@gres_length)

    args = ["-o %G"]
    args.push(cluster_args)

    o, e, s = Open3.capture3(sinfo_cmd, *args)

    if s.success?
      # For each line returned from the command output, calculate the length of each newline,
      # and finally return the maximum line length found.
      @gres_length = o.lines.map(&:strip).map(&:length).max
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving GRES lsength from SLURM. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Parse and return total number of GPU nodes in a SLURM cluster
  # @return [Integer] number of GPU nodes
  def gpu_nodes
    return @available_gpu_nodes if defined?(@available_gpu_nodes)

    o, e, s = Open3.capture3("#{sinfo_cmd} #{cluster_args} -N -h -a --Format='nodehost,gres:#{gres_length}'")

    if s.success?
      @available_gpu_nodes = o.lines.uniq.grep(/gpu:/).count
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving available GPU nodes. Exit status #{s.exitstatus}: #{e.to_s}"
      0
    end
  end

  # Return number of GPU nodes with mixed or idle status
  # 
  # @return [Integer] number of GPU nodes with status mixed (some CPUs allocated)
  def gpu_nodes_free
    return @gpu_nodes_free if defined?(@gpu_nodes_free)

    o, e, s = Open3.capture3("#{sinfo_cmd} #{cluster_args} -a -h --Node --Format='nodehost,gres:#{gres_length},statelong'")

    if s.success?
      @gpu_nodes_free = o.lines.uniq.grep(/gpu:/).grep(/idle/).count
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving free GPU nodes. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  # Return number of GPU nodes in use
  # 
  # @return [Integer] gpu nodes in use
  def gpu_nodes_active
    return @gpu_nodes_active if defined?(@gpu_nodes_active)

    @gpu_nodes_active = available_gpu_nodes - gpu_nodes_free
  end

  # Returns percentage of GPU nodes that are available
  # 
  # @return [Float] percentage gpu nodes available
  def gpu_nodes_available_percent
    gpu_nodes > 0 ? ((gpu_nodes - gpu_nodes_free).to_f / gpu_nodes.to_f) * 100 : 0
  end

  # Number of pending jobs requesting GPUs
  # 
  # @return [Integer] number of pending jobs requesting GPUs
  def gpu_jobs_pending
    return @gpu_jobs_pending if defined?(@gpu_jobs_pending)

    o, e, s = Open3.capture3("#{squeue_cmd} #{cluster_args} --states=PENDING -O 'jobid,tres-pefr-job:#{gres_length},tres-per-node:#{gres_length},tres-per-socket:#{gres_length},tres-per-task:#{gres_length}' -h")

    if s.success?
      @gpu_jobs_pending = o.lines.grep(/gpu:/).count
    else
      # Return stderr as error message
      @error_message = "An error occurred when retrieving pending jobs requesting GPUs. Exit status #{s.exitstatus}: #{o.to_s}"
      0
    end
  end

  def cluster_info
    sinfo_out               = sinfo.split('/')
    running_jobs            = 0
    pending_jobs            = 0
    squeue_jobs_running.split("\n").each{ |line| running_jobs += 1 }
    squeue_jobs_pending.split("\n").each{ |line| pending_jobs += 1 }

    sinfo_out.each{ |line|
      # Strip extra chars returned by Slurm
      line.gsub!('"', '')
      line.gsub!('=', '')
    }

    {
      procs_used:     sinfo_out[0].to_i,
      procs_avail:    sinfo_out[3].to_i,
      nodes_used:     sinfo_out[4].to_i,
      nodes_idle:     sinfo_out[5].to_i,
      nodes_avail:    sinfo_out[6].to_i,
      available_jobs: running_jobs.to_i,
      pending_jobs:   pending_jobs.to_i,
    }
  end

  def setup
    self.active_jobs   = cluster_info[:available_jobs]
    self.eligible_jobs = cluster_info[:pending_jobs]
    self.blocked_jobs  = cluster_info[:blocked_jobs]

    self.procs_used    = cluster_info[:procs_used]
    self.procs_avail   = cluster_info[:procs_avail]
    self.nodes_used    = cluster_info[:nodes_used]
    self.nodes_avail   = cluster_info[:nodes_avail]

    self
  rescue => e
    # TODO Add logging and a flash message that was removed from the controller
    # SlurmSqueueClientNotAvailable.new(cluster_id, cluster_title, e)
  end

  # Return the active jobs as percent of available jobs
  #
  # @return [Float] The percentage active as float
  def active_percent
    available_jobs > 0 ? (active_jobs.to_f / available_jobs.to_f) * 100 : 0
  end

  # Return the eligible jobs as percent of available jobs
  #
  # @return [Float] The percentage eligible as float
  def eligible_percent
    available_jobs > 0 ? (eligible_jobs.to_f / available_jobs.to_f) * 100 : 0
  end

  # Total active + eligible
  #
  # @return [Integer] the total number of active/eligible jobs
  def available_jobs
    active_jobs + eligible_jobs
  end 

  # Total nodes available (idle) and total nodes used
  #
  # @return [Integer] the total number of idle/used jobs
  def available_nodes
    nodes_avail
  end

  # Total number of available and in use procs
  #
  # @return [Integer] the total number of procs 
  def available_procs
    procs_avail
  end

  # Return the processor usage as percent
  #
  # @return [Float] The number of processors used as float
  def procs_percent
    available_procs > 0 ? (procs_used.to_f / available_procs.to_f) * 100 : 0
  end

  # Return the node usage as percent
  #
  # @return [Float] The number of nodes used as float
  def nodes_percent
    available_nodes > 0 ? (nodes_used.to_f / available_nodes.to_f) * 100 : 0
  end
  
  # Return cluster title + error message
  #
  # @return nil or constructed error message
  def friendly_error_message
    error_message.nil? ? nil : "#{cluster_title} Cluster: #{error_message}"
  end

  private

    attr_writer :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail,:error_message, :cluster_id, :cluster_title

    # assign 0 if the input is nil or empty
    def assign(match_string)
      !match_string.blank? ? match_string : 0
    end
end
