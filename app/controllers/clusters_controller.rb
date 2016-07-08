class ClustersController < ApplicationController

  def index
    @clusters = get_clusters
  end

  def show
    cluster = OODClusters.fetch(params[:id].to_sym, nil)
    if cluster.nil?
      render_404
    else
      @ganglia = Ganglia.new(cluster)
      render "system_status"
    end
  end

  private

  def get_clusters
    clusters = Hash.new

    OODClusters.each do |key, cluster|
      ganglia_cluster = Hash.new
      begin
        showqer = MoabShowqClient.new key.to_s
        showqer.setup
      rescue Exception => e
        logger.error "Loading #{cluster.title} showq data failed #{e.message}"
        logger.error e.backtrace.join("\n")
        flash.now[:alert] = "Error loading showq data."
        showqer = MoabShowqClientNotAvailable.new
      end
      ganglia_cluster[:showqer] = showqer
      clusters[key] = ganglia_cluster
      end

    return clusters
  end

  def render_404
    respond_to do |format|
      format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
      format.xml  { head :not_found }
      format.any  { head :not_found }
    end
  end
end
