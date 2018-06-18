require 'moab'
class MoabShowqClientNotAvailable < MoabShowqClient
  def initialize
    self.active_jobs = self.eligible_jobs = self.blocked_jobs = self.procs_used = self.procs_avail = self.nodes_used = self.nodes_avail = 0
  end
end
