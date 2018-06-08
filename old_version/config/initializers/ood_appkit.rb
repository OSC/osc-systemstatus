# config/initializers/ood_appkit.rb

OODClusters = OodCore::Clusters.new(
    OodAppkit.clusters.select(&:job_allow?)
        .select { |c| c.custom_config[:moab] }
        .select { |c| c.custom_config[:ganglia] }
        .reject { |c| c.metadata.hidden }
)
