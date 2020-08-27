class SlurmSqueueClient

  attr_reader :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail, :error_message, :dashboard_url, :cluster_id, :cluster_title, :friendly_error_message

  # Set the object to the server.
  #
  # @param [OodAppkit::Cluster]
  #
  # @return [SlurmSqueueClient] self
  def initialize(cluster)
    @server = cluster.job_config[:bin]
  
    if cluster.custom_config.key?(:grafana)
      @dashboard_url = "/clusters/#{cluster.id}/grafana"
    end
  
    @cluster_id = cluster.id
    @cluster_title = cluster.metadata.title || cluster.id.titleize
    @job_scheduler = cluster.job_config[:adapter]

    self
  end

  # Return job scheduler type from config
  def job_scheduler_name
    @job_scheduler
  end

  # Get pending jobs
  def squeue_jobs_pending
    cmd = '/usr/bin/squeue'
    args = ["-h", "--all", "--states=PENDING"]
  
    o, e, s = Open3.capture3({}, cmd, *args)
    
    s.success? ? o : raise(CommandFailed, e)
  end

  # Get running jobs
  def squeue_jobs_running
    cmd = '/usr/bin/squeue'
    args = ["-h", "--all", "--states=RUNNING"]
  
    o, e, s = Open3.capture3({}, cmd, *args)
    
    s.success? ? o : raise(CommandFailed, e)
  end

  # Get cluster info (node count, core count, etc.)
  def sinfo
    cmd = '/usr/bin/sinfo'
    args = ["-s", "-h", "-o=\"%C/%A\""]
  
    o, e, s = Open3.capture3({}, cmd, *args)
    
    s.success? ? o : raise(CommandFailed, e)
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
      procs_avail:    sinfo_out[1].to_i,
      nodes_used:     sinfo_out[4].to_i,
      nodes_idle:     sinfo_out[5].to_i,
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
    self.nodes_avail   = cluster_info[:nodes_idle]

    self
  rescue => e
    # TODO Add logging and a flash message that was removed from the controller
    # SlurmSqueueClientNotAvailable.new(cluster_id, cluster_title, e)
  end
  
  # Return moab lib pathname
  def moab_lib
    Pathname.new(@server['lib'].to_s)
  end
  
  # Return moab bin pathname
  def moab_bin
    Pathname.new(@server['bin'].to_s)
  end
  
  # Return moab home directory pathname
  def moab_home 
    Pathname.new(@server['homedir'].to_s)
  end

  # Return total CPU cores 
  def total_cpu_cores
    cmd = "sinfo"
    # $ sinfo -s -h -o="%C"
    #   allocated/idle/other/total
    #   =960/18144/192/19296
    # 0 1 2 3
    args = ["-s", "-h", "-o=\"%C\"\\"]
    env = {}.merge(env.to_h)
    o, e, s = Open3.capture3(env, cmd, *args)
    raise(CommandFailed, e) unless s.success?

    lines = o.split("/")
    lines[3].to_i
  end

  # Return total CPU cores 
  def used_cpu_cores
    cmd = "sinfo"
    # $ sinfo -s -h -o="%C"
    #   allocated/idle/other/total
    #   =960/18144/192/19296
    # 0 1 2 3
    args = ["-s", "-h", "-o=\"%C\"\\"]
    env = {}.merge(env.to_h)
    o, e, s = Open3.capture3(env, cmd, *args)
    raise(CommandFailed, e) unless s.success?

    lines = o.split("/")
    lines.each{ |line|
      # Strip extra chars returned by Slurm
      line.gsub!('"', '')
      line.gsub!('=', '')
    }
    lines[0].to_i
  end

  # Return the active jobs as percent of available jobs
  #
  # @return [Float] The percentage active as float
  def active_percent
    (active_jobs.to_f / available_jobs.to_f) * 100
  end

  # Return the eligible jobs as percent of available jobs
  #
  # @return [Float] The percentage eligible as float
  def eligible_percent
    (eligible_jobs.to_f / available_jobs.to_f) * 100
  end

  # Total active + eligible
  #
  # @return [Integer] the total number of active/eligible jobs
  def available_jobs
    active_jobs + eligible_jobs
  end

  # Return the processor usage as percent
  #
  # @return [Float] The number of processors used as float
  def procs_percent
    (procs_used.to_f / procs_avail.to_f) * 100
  end

  # Return the node usage as percent
  #
  # @return [Float] The number of nodes used as float
  def nodes_percent
    (nodes_used.to_f / nodes_avail.to_f) * 100
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
