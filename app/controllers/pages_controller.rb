class PagesController < ApplicationController

  def index
    begin
      @showqoakley = Showqer.new 'oakley'
      @showqoakley.setup
    rescue Exception => e
      logger.error "Loading Oakley showq data failed #{e.message}"
      logger.error e.backtrace.join("\n")
      flash.now[:alert] = "Error loading showq data."
      @showqoakley = ShowqerNotAvailable.new
    end

    begin
      @showqruby = Showqer.new 'ruby'
      @showqruby.setup
    rescue Exception => e
      logger.error "Loading Ruby showq data failed #{e.message}"
      logger.error e.backtrace.join("\n")
      flash.now[:alert] = "Error loading showq data."
      @showqruby = ShowqerNotAvailable.new
    end
  end

  def oakley
    @ganglia = Ganglia.new.oakley
    render "system_status"
  end

  def ruby
    @ganglia = Ganglia.new.ruby
    render "system_status"
  end

  def about
  end
end
