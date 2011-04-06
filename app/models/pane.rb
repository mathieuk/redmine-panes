class Pane < ActiveRecord::Base
	unloadable
	
	has_many :subpanes, :class_name => "Pane", :foreign_key => "parent_pane_id"
	belongs_to :pane
	
	belongs_to :status, :class_name => "IssueStatus", :foreign_key => "status_id"

	def issues (tracker_ids=[])
		Issue.find :all, :conditions => "status_id = #{self.status_id} AND tracker_id IN (" + tracker_ids.join(',') + ")"
	end
end
