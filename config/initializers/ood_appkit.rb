# config/initializers/ood_appkit.rb

#OODClusters = OodAppkit.clusters.select do |c|
#  c.valid? && c.hpc_cluster? &&
#    c.ganglia_server? &&
#    c.scheduler_server? &&
#    c.scheduler_server.is_a?(OodCluster::Servers::Moab)
#end.each_with_object({}) { |c, h| h[c.id] = c }

OODClusters = OodCore::Clusters.new(
    OodAppkit.clusters.select(&:job_allow?)
        .select { |c| c.custom_config[:moab] }
        .reject { |c| c.metadata.hidden }
)
