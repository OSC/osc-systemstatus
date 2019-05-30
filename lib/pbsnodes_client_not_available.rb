class PBSNodesClientNotAvailable < PBSNodesClient
  def initialize(id, title, message)
    self.gpus_available = self.gpus_used = 0
    self.cluster_id = id
    self.cluster_title = title
    self.error_message = message
    self
  end
end