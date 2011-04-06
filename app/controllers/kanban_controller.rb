class KanbanController < ApplicationController
	unloadable
	before_filter :load_project, :authorize
	# Loads the project to be used by the authorize filter to
	# determine if User.current has permission to invoke the method in question.
	def load_project
	  @project = if params[:issue_id]
	               issue = Issue.find(params[:issue_id])
	               issue.project
	             elsif params[:release_id]
	               load_release
	               @release.project
	             elsif params[:project_id]
	               Project.find(params[:project_id])
	             else
	               raise "Cannot determine project (#{params.inspect})"
	             end
	end
	
	def update_pane
		result = {
			'success' => false
		}
		
		if params[:issue_id] && params[:status_id]
			issue = Issue.find(params[:issue_id])
			old_status = issue.status
			
			issue.init_journal(User.current)
		    issue.safe_attributes = {
				'status_id' => params[:status_id]
			}
			
			issue.save
			
			result['success'] = issue.status != old_status
			
		end

		render :json => result.to_json
	end
	
 	def edit_issue
		@issue = Issue.find(params[:issue_id])
		
		if request.post?
			Rails.logger.info("PARAMS: #{params[:issue].inspect}")
			@issue.init_journal(User.current)
		
			@issue.safe_attributes = params[:issue];
	
			@issue.save
			
			redirect_to :action => 'index', :project_id => @project.id
		    
		end
	end

	def index
		@panes = Pane.find(:all, :conditions => "parent_pane_id IS NULL", :order=> "position")
		
		@task_trackers = [1,2,4]
		@urgent_trackers = [5]
	end
	
end
