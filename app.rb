require 'sinatra'
require 'ood_core'
require 'moab'

Dir[File.dirname(__FILE__) + "/lib/*.rb"].each {|file| require_relative file }

helpers do

  def parse_clusters
    config = ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d'
    OodCore::Clusters.load_file(config)
  rescue OodCore::ConfigurationNotFound
    OodCore::Clusters.new([])
  end
  # more details see ood_appkit lib/ood_appkit/configuration.rb
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

  def dashboard_title
    ENV['OOD_DASHBOARD_TITLE'] || "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def relative_url
    ENV["RAILS_RELATIVE_URL_ROOT"] || "/pun/sys/systemstatus/"
  end

end

before do
  @clusters||=valid_clusters
end

get '/clusters/:id' do
  id=params[:id].to_sym
  cluster = @clusters[id]
  if cluster.nil?
    raise Sinatra::NotFound
  else
    @ganglia = Ganglia.new(cluster)
    erb :system_status
  end
end

# redirect to /clusters page
get '/' do
  redirect(url('/clusters'))
end

get '/clusters' do
  erb :index
end

# 404 not found
not_found do
  erb :not_found
end

# 500 internal server error
error do
  erb :internal_server_error
end
