class ClustersController < ApplicationController

  def index
  end

  def show
    cluster = OODClusters[params[:id].to_sym] || nil
    if cluster.nil?
      render_404
    else
      @ganglia = Ganglia.new(cluster)
      render "system_status"
    end
  end

  private

    def render_404
      respond_to do |format|
        format.html { render :file => "public/404", :layout => false, :status => :not_found }
        format.xml  { head :not_found }
        format.any  { head :not_found }
      end
    end
end
