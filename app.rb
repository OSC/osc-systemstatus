require 'sinatra'
require 'ood_core'
require 'moab'

Dir[File.dirname(__FILE__) + "/classes/*.rb"].each {|file| require_relative file }

# register Sinatra::ConfigFile
# config_file 'env.yml'

configure do
  # The app's configuration root directory
  # set :config_root, ENV["OOD_APP_CONFIG_ROOT"] || "/etc/ood/config/apps/systemstatus"
  # Default file paths
  set :environments, %w{development test production}
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
  set :session, false
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

helpers do

  def parse_clusters
    config = ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d'
    OodCore::Clusters.load_file(config)
  rescue OodCore::ConfigurationNotFound
    OodCore::Clusters.new([])
  end

  def valid_clusters
    clusters = parse_clusters
    OodCore::Clusters.new(
      clusters.select(&:job_allow?)
          .select { |c| c.custom_config[:moab] }
          .select { |c| c.custom_config[:ganglia] }
          .reject { |c| c.metadata.hidden }
    )
  end

end

# def initialize(app=nil)
#   super()
#   clusters=OodCore::Clusters.load_file(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d' ) || OodCore::Clusters.new([])
#   @oodclusters = OodCore::Clusters.new(
#     clusters.select(&:job_allow?)
#          .select { |c| c.custom_config[:moab] }
#          .select { |c| c.custom_config[:ganglia] }
#          .reject { |c| c.metadata.hidden }
#      )
# end

before do
  @oodclusters=valid_clusters
end

get '/' do
  erb :index
end

get 'clusters/:id' do
  @oodclusters=valid_clusters
  id=params[:id]
  cluster = @oodclusters[id.to_sym]|| nil
  if cluster.nil?
    'nothing'
  else
    @ganglia = Ganglia.new(cluster)
    erb :system_status
  end
end

get '/about' do
  erb :about
end

# get '/not-found' do
#   File.read('404.html')
# end

# 404 not found
not_found do
  status 404
  File.read(settings.public_folder+'/404.html')
end

# 500 internal server error
error do
  File.read(settings.public_folder+'/500.html')
end
