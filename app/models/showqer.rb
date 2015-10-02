# Utility class for getting numerical data from showq
#
# @author Brian L. McMichael
# @version 0.0.1
#
# TODO: parse once and assign instance vars.
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
  # @return [Showqer] self
  def server(server='oakley')
    @server = OSC_Servers[server] ||= OSC_Servers['oakley']
    self
  end

  # Return the number of active jobs
  #
  # TODO: Error handling.
  #
  # @return [Integer] The number of active jobs
  def active_jobs
    @showq.match(/\d+ active jobs/)[0].scan(/\d+/).first.to_i
  end

  def active_percent
    (active_jobs.to_f / total_jobs.to_f) * 100
  end

  # Return the number of eligible jobs
  #
  # TODO: Error handling.
  #
  # @return [Integer] The number of eligible jobs
  def eligible_jobs
    @showq.match(/\d+ eligible jobs/)[0].scan(/\d+/).first.to_i

  end

  def eligible_percent
    (eligible_jobs.to_f / total_jobs.to_f) * 100
  end

  # Return the number of blocked jobs
  #
  # TODO: Error handling.
  #
  # @return [Integer] The number of blocked jobs
  def blocked_jobs
    @showq.match(/\d+ blocked jobs/)[0].scan(/\d+/).first.to_i
  end

  def blocked_percent
    (blocked_jobs.to_f / total_jobs.to_f) * 100
  end

  # Total active + eligible + blocked jobs
  #
  # @return [Integer] the total number of active/eligible/blocked jobs
  def total_jobs
    active_jobs + eligible_jobs + blocked_jobs
  end

  # Return the number of processors in use
  #
  # @return [Integer] The number processors in use
  def procs_used
    @showq.match(/\d+ of \d+ processors/)[0].scan(/\d+/).first.to_i
  end

  # Return the number of processors available
  #
  # @return [Integer] The number of available processors
  def procs_avail
    @showq.match(/\d+ of \d+ processors/)[0].scan(/\d+/).second.to_i
  end

  # Return the processor usage as percent
  #
  # @return [Float] The number of processors used as float to two precision points
  def procs_percent
    ((procs_used.to_f / procs_avail.to_f) * 100).round(2)
  end

  # Return the number of nodes in use
  #
  # @return [Integer] The number of nodes in use
  def nodes_used
    @showq.match(/\d+ of \d+ nodes/)[0].scan(/\d+/).first.to_i
  end

  # Return the number of available nodes
  #
  # @return [Integer] The number of available nodes
  def nodes_avail
    @showq.match(/\d+ of \d+ nodes/)[0].scan(/\d+/).second.to_i
  end

  # Return the node usage as percent
  #
  # @return [Float] The number of nodes used as float to two precision points
  def nodes_percent
    ((nodes_used.to_f / nodes_avail.to_f) * 100).round(2)
  end

  # Show the result of the showq command.
  def to_s
    @showq
  end

end