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
  def h(text)
    Rack::Utils.escape_html(text)
  end

  def dashboard_title
    ENV['OOD_DASHBOARD_TITLE'] || "Open OnDemand"
  end

  def dashboard_url
    "/pun/sys/dashboard/"
  end

  def public_url
     ENV['OOD_PUBLIC_URL'] || "/public"
  end
  
end

get '/clusters/:id/:time' do
  @id=params[:id].to_sym
  @time=params[:time]
  cluster = CLUSTERS[@id]
  if cluster.nil?
    raise Sinatra::NotFound
  else
    @ganglia = eval("(Ganglia.new(cluster)).#{@time}")
    erb :system_status
  end
end

# redirect to /clusters page
get '/clusters/:id' do
  redirect(url("/clusters/#{params[:id]}/hour"))
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
