class Pane
  attr_accessor :title, :wip_limit, :issuestatus, :issues

  def initialize(title, wip_limit, status, issues)
	@title       = title
	@wip_limit   = wip_limit
    @issuestatus = status
    @issues      = issues
  end
  
end

    