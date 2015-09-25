# Utility class for building string requests to the Ganglia Server
#
# @author Brian L. McMichael
# @version 0.0.1
#
# Oakley CPU Request Example:
#   https://cts05.osc.edu/od_monitor/graph.php?r=hour&g=cpu_report&m=boottime&z=medium&openid_identifier=https%3A%2F%2Fopenid.osc.edu%2Fopenid%2Fbmcmichael&c=Oakley+nodes&timestamp=1443022607901
#
# Ruby CPU Request Example:
#   https://cts05.osc.edu/od_monitor/graph.php?r=hour&g=cpu_report&m=boottime&z=medium&openid_identifier=https%3A%2F%2Fopenid.osc.edu%2Fopenid%2Fbmcmichael&c=Ruby&timestamp=1443022949805
#
# Fileserver CPU Request Example:
#   https://cts05.osc.edu/od_monitor/graph.php?r=hour&amp;g=load_report&amp;m=boottime&amp;z=medium&amp;openid_identifier=https%3A%2F%2Fopenid.osc.edu%2Fopenid%2Fbmcmichael&amp;c=XIO&amp;h=xio45.ten.osc.edu&amp;timestamp=1443023006430
#
class Ganglia

  GANGLIA_HOST = 'https://cts05.osc.edu/od_monitor/graph.php?'

  # @option 'oakley'
  # @option 'ruby'
  # @option 'fileserver'
  def initialize(server='oakley')
    self.server(server)
    self.hour
    self.report_cpu
    self.small
    self
  end

  # Set the server to a server in servers.yml
  # Default is Oakley if input is invalid
  #
  # @param [String] The server name
  def server(server)
    @server = OSC_Servers[server] ||= OSC_Servers['oakley']
    self
  end

  # Set the server to Oakley
  def oakley
    self.server('oakley')
  end

  # Set the server to Ruby
  def ruby
    self.server('ruby')
  end

  # Set the server to the File Server
  def fileserver
    self.server('fileserver')
  end

  # Define the time-ago range for the data.
  #
  # @option 'hour'
  # @option '2hr'
  # @option '4hr'
  # @option 'day'
  # @option 'week'
  # @option 'month'
  # @option 'year'
  def range(ganglia_range)
    @range = ganglia_range
    self
  end

  # Set the range to one hour
  def hour
    @range = 'hour'
    self
  end

  # Set the range to two hours
  def two_hours
    @range = '2hr'
    self
  end

  # Set the range to four hours
  def four_hours
    @range = '4hr'
    self
  end

  # Set the range to 24 hours
  def day
    @range = 'day'
    self
  end

  # Set the range to a week
  def week
    @range = 'week'
    self
  end

  # Set the range to a month
  def month
    @range = 'month'
    self
  end

  # Set the range to a year
  def year
    @range = 'year'
    self
  end

  # Set the report type to CPU
  def report_cpu
    @report_type = 'cpu_report'
    self
  end

  # Set the report type to Load
  def report_load
    @report_type = 'load_report'
    self
  end

  # Set the report type to Memory
  def report_mem
    @report_type = 'mem_report'
    self
  end

  # Set the report type to Network
  def report_network
    @report_type = 'network_report'
    self
  end

  # Set the report type to packet
  def report_packet
    @report_type = 'packet_report'
    self
  end

  def small
    @chart_size = 'small'
    self
  end

  def medium
    @chart_size = 'medium'
    self
  end

  def large
    @chart_size = 'large'
    self
  end

  # Builds a request that returns a png response from the ganglia server
  def img
    "#{GANGLIA_HOST}#{range}#{report_type}#{chart_size}#{openid_user}#{cluster}#{time}"
  end

  # Builds a request that returns a json response from the ganglia server
  def json
    "#{self.img}&json=true"
  end

  private

    def fileserver_node
      if @server == OSC_Servers['fileserver']
        # ex: /nfs/08/bmcmichael
        path = ENV['HOME']
        # get the number from the nfs path
        fileserver_number = path.scan(/^\/nfs\/([0-9]{2})\//).first.first
        # map to the xio
        node = OSC_Servers["fileserver"]["fs#{fileserver_number}"]
        "&h=#{node}"
      end
    end

    def range
      "&r=#{@range}"
    end

    def report_type
      "&g=#{@report_type}"
    end

    def chart_size
      "&z=#{@chart_size}"
    end

    def openid_user
      "&openid_identifier=#{ENV['REMOTE_USER']}"
    end

    def cluster
      "&c=#{@server['cluster_code']}#{fileserver_node}"
    end

    def time
      current_server_time = Time.now.to_i
      "&timestamp=#{current_server_time}"
    end

end