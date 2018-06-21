require 'sinatra'
require 'ood_core'
require 'moab'

Dir[File.dirname(__FILE__) + "/lib/*.rb"].each {|file| require_relative file }

configure do
  set :environments, %w{development test production}
  set :root, File.dirname(__FILE__)
  set :public_folder, settings.root+"/public"
  set :views, settings.root + "/views"
end

configure :production do
  enable :logging
  # set :logging, Logger::INFO
  set :dump_errors, false
  disable :static
end


# app will run dev mode by default
configure :development do
  enable :logging
  set :session, false
 # set :logging, Logger::DEBUG
  set :dump_errors, true
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

  def h(text)
    Rack::Utils.escape_html(text)
  end

end

before do
  @oodclusters=valid_clusters
end

get '/clusters/:id' do
  id=params[:id].to_sym
  cluster = @oodclusters[id]|| nil
  if cluster.nil?
    File.read('404.html')
  else
    @ganglia = Ganglia.new(cluster)
    erb :system_status
  end
end

get '/about' do
  erb :about
end

get '/' do
  erb :index
end

get '/clusters' do
  erb :index
end

# 404 not found
not_found do
  status 404
  File.read(settings.public_folder+'/404.html')
end

# 500 internal server error
error do
  File.read(settings.public_folder+'/500.html')
end
