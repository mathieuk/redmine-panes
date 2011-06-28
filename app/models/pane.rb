class Pane < ActiveRecord::Base
	unloadable
	
	has_many :subpanes, :class_name => "Pane", :foreign_key => "parent_pane_id"
	belongs_to :pane
	
	belongs_to :status,  :class_name => "IssueStatus", :foreign_key => "status_id"
	belongs_to :project, :class_name => "Project", :foreign_key => "project_id"
	
	def issues (tracker_ids=[], parent_issue_id = nil)
		parent_id = "NULL"
		
		if (parent_issue_id)
			parent_id = " = " + parent_issue_id.to_s
		else
			parent_id = " IS NULL"
		end
			
		Issue.find :all, 
			:conditions => "status_id = #{self.status_id} AND project_id = " + project.id.to_s + " AND tracker_id IN (" + tracker_ids.join(',') + ") AND parent_id " + parent_id
	end
		
end
