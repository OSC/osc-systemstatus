class MoabShowqClientNotAvailable < MoabShowqClient
  def initialize(message)
    self.active_jobs = self.eligible_jobs = self.blocked_jobs = self.procs_used = self.procs_avail = self.nodes_used = self.nodes_avail = 0
    self.error_message = message
    self
  end
end
