# Utility class for getting numerical data from showq
#
# @author Brian L. McMichael
# @version 0.0.1
class Showqer

  # Set the object to the server.
  #
  # @option 'oakley'
  # @option 'ruby'
  #
  # @return [Showqer] self
  def initialize(server)
    self.server(server)
    @showq = %x{ showq --host=#{@server['pbshost']} }
  end

  # Set the server to a server in servers.yml
  #
  # Default: Oakley if input is invalid
  #
  # @param [String] The server name
  #
  # @return [Ganglia] self
  def server(server='oakley')
    @server = OSC_Servers[server] ||= OSC_Servers['oakley']
    self
  end

  def active_jobs
    @showq.match(/\d+ active jobs/)[0].scan(/\d+/).first.to_i
  end

  def eligible_jobs
    @showq.match(/\d+ eligible jobs/)[0].scan(/\d+/).first.to_i

  end

  def blocked_jobs
    @showq.match(/\d+ blocked jobs/)[0].scan(/\d+/).first.to_i
  end

  def procs_used
    @showq.match(/\d+ of \d+ processors/)[0].scan(/\d+/).first.to_i
  end

  def procs_avail
    @showq.match(/\d+ of \d+ processors/)[0].scan(/\d+/).second.to_i
  end

  def procs_percent
    ((procs_used.to_f / procs_avail.to_f) * 100).round(2)
  end

  def nodes_used
    @showq.match(/\d+ of \d+ nodes/)[0].scan(/\d+/).first.to_i
  end

  def nodes_avail
    @showq.match(/\d+ of \d+ nodes/)[0].scan(/\d+/).second.to_i
  end

  def nodes_percent
    ((nodes_used.to_f / nodes_avail.to_f) * 100).round(2)
  end

  # Show the result of the showq command.
  def to_s
    @showq
  end

end