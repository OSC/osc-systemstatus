require 'sinatra'
require 'ood_core'
require 'rexml/document'
require 'open3'
require 'pathname'
Dir[File.dirname(__FILE__) + "/lib/*.rb"].each {|file| require_relative file }

# more details see ood_appkit lib/ood_appkit/configuration.rb
begin
  CLUSTERS = OodCore::Clusters.new(OodCore::Clusters.load_file(ENV['OOD_CLUSTERS'] || '/etc/ood/config/clusters.d').select(&:job_allow?)
            .select { |c| c.custom_config[:moab] }
            .select { |c| c.custom_config[:ganglia] }
            .reject { |c| c.metadata.hidden }
          )
rescue OodCore::ConfigurationNotFound
  CLUSTERS = OodCore::Clusters.new([])
end

helpers do
  def dashboard_title
    ENV['OOD_DASHBOARD_TITLE'] || "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def public_url
     ENV['OOD_PUBLIC_URL'] || "/public"
  end
  
  def graph_time
      {:hour => 'Hour', :two_hours => '2 Hours', :four_hours => '4 Hours', :day => 'Day', :week => 'Week', :month => 'Month', :year => 'Year'}
  end
  
  def graph_types
    {:report_moab_nodes => 'Nodes', :report_moab_jobs => 'Jobs', :report_load => 'Load', :report_network => 'Network'}
  end
end

get '/clusters/:id/:time/:type' do
  @id=params[:id].to_sym
  graph_time.keys.include?(params[:time].to_sym) ? @time=params[:time].to_sym : @time=:hour
  graph_types.keys.include?(params[:type].to_sym) ? @type=params[:type].to_sym : @type=:report_moab_nodes
  cluster = CLUSTERS[@id]
  if cluster.nil?
    raise Sinatra::NotFound
  else
    @ganglia = Ganglia.new(cluster).send(@time)
    erb :system_status
  end
end


# redirect to /clusters/:id/hour/report_moab_nodes page
get '/clusters/:id*' do
  redirect(url("/clusters/#{params[:id]}/hour/report_moab_nodes"))
end

# redirect to /clusters page
get '/' do
  redirect(url('/clusters'))
end

get '/clusters' do
  @clusters = CLUSTERS.map { |cluster| MoabShowqClient.new(cluster).setup }
  @error_messages = (@clusters.map{ |cluster| cluster.friendly_error_message}).compact 
  erb :index
end

# 404 not found
not_found do
  erb :'404'
end

# 500 internal server error
error do
  erb :'500'
end
