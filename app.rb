require 'sinatra/base'
require 'ood_core'
#require 'sinatra/cookies'
# require "sinatra/config_file"
require_relative 'classes/ganglia.rb'
require_relative 'classes/moab_showq_client.rb'
require_relative 'classes/moab_showq_client_not_available.rb'
# writing logging to STDERR is enabled by default
class SystemStatusApp < Sinatra::Application
  # register Sinatra::ConfigFile
  # config_file 'env.yml'
  set :environments, %w{development test production}

  configure do
    # The app's configuration root directory
    # set :config_root, ENV["OOD_APP_CONFIG_ROOT"] || "/etc/ood/config/apps/systemstatus"
    # Default file paths
    set :root, File.dirname(__FILE__)
    set :public_folder, settings.root+"/public"
    set :views, settings.root + "/views"

  end

  # rackup -E production config.ru
  # Defaults to ENV['APP_ENV'], or "development" if not available

  configure :production do
  #  use Rack::Session::Cookie, :key => 'rack.session',
   #                            :path => '/',
    #                           :secret =>'773216139fce1f010e015a6cbc2769f94080f477fbbfa76fbfa72d9235dc69ba359563f1699752e4d0872aed5a222f636c030b40999b51cb13c498389f99690e'

    enable :logging
    # set :logging, Logger::INFO
    set :dump_errors, false
    disable :static
    # set :RAILS_RELATIVE_URL_ROOT, File.dirname('/pun/sys/systemstatus')
    # set :OOD_DATAROOT, File.dirname($HOME/ondemand/data/sys/systemstatus)
    # set :DATAROOT, ENV["OOD_DATAROOT"] || ENV["RAILS_DATAROOT"] || File.dirname("~/#{ENV['OOD_PORTAL'] || 'ondemand'}/data/#{ENV['APP_TOKEN'] || 'sys/systemstatus'}")
  end


  # app will run dev mode by default
  configure :development do
    enable :logging
   # set :logging, Logger::DEBUG
    set :dump_errors, true
  #  set :DATAROOT, ENV["OOD_DATAROOT"] || ENV["RAILS_DATAROOT"] || File.dirname(setting.root,'data')
  end

  configure :test do
    # Configure static asset server for tests with Cache-Control for performance.
    enable :static
    set :static_cache_control, [:public, :max_age => 3600]
    # Raise exceptions instead of rendering exception templates.
    # Enabled by default when environment is set to "development", disabled otherwise.
    disable :show_exceptions
    # Show full error reports
    set :dump_errors, true
    #set :DATAROOT, ENV["OOD_DATAROOT"] || ENV["RAILS_DATAROOT"] || File.dirname(setting.root,'data')
  end

  def initialize(app=nil)
    super()
    @OODClusters = OodCore::Clusters.new(
      OodCore::Clusters.load_file('/etc/ood/config/clusters.d').select(&:job_allow?)
          .select { |c| c.custom_config[:moab] }
          .select { |c| c.custom_config[:ganglia] }
          .reject { |c| c.metadata.hidden }
    )

  end


  get '/' do
    erb :index, :layout => :application
  end

  get 'clusters/:id' do
    cluster = @OODClusters[params[:id].to_sym] || nil
    if cluster.nil?
      File.read('404.html')
    else
      @ganglia = Ganglia.new(cluster)
      erb :system_status, :layout => :application
    end
  end

  get '/about' do
    erb :about, :layout => :application
  end

  # get '/not-found' do
  #   File.read('404.html')
  # end

  # 404 not found
  not_found do
    status 404
    File.read('404.html')
  end

  # 500 internal server error
  error do
    File.read('500.html')
  end
end
