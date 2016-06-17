class PagesController < ApplicationController

  def index
    @showqoakley = Showqer.new 'oakley'
    @showqruby = Showqer.new 'ruby'
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
