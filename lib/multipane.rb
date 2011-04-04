class Multipane
	attr_accessor :title, :wip_limit, :panes
	
	def initialize(title, wip_limit, panes)
		@title = title
		@panes = panes
		@wip_limit = wip_limit
	end
end
		