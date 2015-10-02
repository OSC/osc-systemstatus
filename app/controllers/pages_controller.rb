class PagesController < ApplicationController

  def index
    @ganglia = Ganglia.new
    @motd = File.open("/etc/motd","rb").read
  end

  def oakley
    @ganglia = Ganglia.new.oakley
    render "system_status"
  end

  def ruby
    @ganglia = Ganglia.new.ruby
    render "system_status"
  end

  def filesystem
    @ganglia = Ganglia.new.fileserver
    render "system_status"
  end

  def about
  end
end
