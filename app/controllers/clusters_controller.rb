class ClustersController < ApplicationController

  def index
    @clusters = get_clusters
  end

  def show
    begin
      cluster = OODClusters.fetch(params[:id].to_sym)
    rescue
      raise "Cluster not found!" if cluster.nil?
    end
    @ganglia = Ganglia.new(params[:id])
    render "system_status"
  end

  private

  def get_clusters
    clusters = Hash.new

    OODClusters.each do |key, cluster|
      if cluster.ganglia_server?
        ganglia_cluster = Hash.new
        begin
          showqer = Showqer.new key.to_s
          showqer.setup
        rescue Exception => e
          logger.error "Loading #{cluster.title} showq data failed #{e.message}"
          logger.error e.backtrace.join("\n")
          flash.now[:alert] = "Error loading showq data."
          showqer = ShowqerNotAvailable.new
        end
        ganglia_cluster[:showqer] = showqer
        clusters[key] = ganglia_cluster
      end
    end
    return clusters
  end
end
