# Utility class for getting numerical data from showq
#
# @author Brian L. McMichael
# @version 0.1.0
class MoabShowqClient

  attr_reader :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail

  # Set the object to the server.
  #
  # @param [OodAppkit::Cluster]
  #
  # @return [MoabShowqClient] self
  def initialize(cluster)
    @server = cluster
    self
  end

  def setup

    # Passenger wipes the PATH so we have to reset it to pull in the moab libraries.
    showqx = %x{ MOABHOMEDIR=#{@server.servers[:scheduler].moabhomedir.to_s} #{@server.servers[:scheduler].prefix.to_s}/bin/showq --xml --host=#{@server.servers[:scheduler].host} }

    showqxdoc = Nokogiri::XML(showqx)

    self.active_jobs = showqxdoc.at_xpath('//queue[@option="active"]/@count').value.to_i
    self.eligible_jobs = showqxdoc.at_xpath('//queue[@option="eligible"]/@count').value.to_i
    self.blocked_jobs = showqxdoc.at_xpath('//queue[@option="blocked"]/@count').value.to_i

    cluster = showqxdoc.xpath("//cluster")
    self.procs_used = cluster.attribute('LocalAllocProcs').value.to_i
    self.procs_avail = cluster.attribute('LocalUpProcs').value.to_i
    self.nodes_used = cluster.attribute('LocalActiveNodes').value.to_i
    self.nodes_avail = cluster.attribute('LocalUpNodes').value.to_i
    self
  rescue
    # TODO Add logging and a flash message that was removed from the controller
    MoabShowqClientNotAvailable.new
  end

  # Return the active jobs as percent of total jobs
  #
  # @return [Float] The percentage active as float
  def active_percent
    (active_jobs.to_f / total_jobs.to_f) * 100
  end

  # Return the eligible jobs as percent of total jobs
  #
  # @return [Float] The percentage eligible as float
  def eligible_percent
    (eligible_jobs.to_f / total_jobs.to_f) * 100
  end

  # Return the blocked jobs as percent of total jobs
  #
  # @return [Float] The percentage blocked as float
  def blocked_percent
    (blocked_jobs.to_f / total_jobs.to_f) * 100
  end

  # Total active + eligible + blocked jobs
  #
  # @return [Integer] the total number of active/eligible/blocked jobs
  def total_jobs
    active_jobs + eligible_jobs + blocked_jobs
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

  private

    attr_writer :active_jobs, :eligible_jobs, :blocked_jobs, :procs_used, :procs_avail, :nodes_used, :nodes_avail

    # assign 0 if the input is nil or empty
    def assign(match_string)
      !match_string.blank? ? match_string : 0
    end

end
