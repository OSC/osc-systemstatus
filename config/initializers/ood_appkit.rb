# config/initializers/ood_appkit.rb

OODClusters = OodAppkit.clusters.hpc.select { |k, c| c.ganglia_server? && c.scheduler_server? && c.scheduler_server.respond_to?(:moabhomedir) }
