module KanbanHelper
	def tracker_name_to_css_class(name)
		name.gsub(/[^a-z0-9_]+/, '_').downcase
	end
end
