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
		@project = Project.find(params[:project_id])
		@panes		 = self.get_pane_configuration(@project)
		@have_multipanes = false
		
		@panes.each do |key, pane|
			if (pane.instance_of? Multipane)
				@have_multipanes = true
			end
		end
		
		@pane_order = ["proposed", "analysis", "development", "test", "deploy"]
		
		@pane_js_data = {}
		@panes.each do |key, pane| 
			@pane_js_data[key] = {
				:title         => pane.title,
				:subpane_count => (pane.instance_of? Multipane) ?  pane.panes.count : 1,
				:wip_limit     => pane.wip_limit
			}
		end
	end
	
	def get_pane_configuration(project)
		panes = Hash.new
		
		new_status		= IssueStatus.find_by_name("Selected")
		proposed_pane = Pane.new(
			"Selected",
			'6',
			new_status,
			project.issues.find_all_by_status_id(new_status.id, :include => [:assigned_to])
		);
		panes["proposed"] = proposed_pane
		
		# Analysis
		analysis_ongoing_status   = IssueStatus.find_by_name("Analysis")
		analysis_completed_status = IssueStatus.find_by_name("Dev Ready")

		ongoing_pane = Pane.new(
			"Doing",
			-1,
			analysis_ongoing_status, 
			project.issues.find_all_by_status_id(analysis_ongoing_status.id, :include => [:assigned_to])
		)

		done_pane = Pane.new(
			"Done",
			-1,
			analysis_completed_status, 
			project.issues.find_all_by_status_id(analysis_completed_status.id, :include => [:assigned_to])
		);

		subpanes = Hash.new	
		subpanes["analysis-ongoing"] = ongoing_pane
		subpanes["analysis-done"] = done_pane
		
		analysis = Multipane.new("Analysis", 3, subpanes)
		panes["analysis"] = analysis
		
		#Development is a multipane
		ongoing_status   = IssueStatus.find_by_name("In Progress")
		completed_status = IssueStatus.find_by_name("Completed")
		
		ongoing_pane = Pane.new(
			"Doing",
			-1,
			ongoing_status, 
			project.issues.find_all_by_status_id(ongoing_status.id, :include => [:assigned_to])
		)

		done_pane = Pane.new(
			"Done",
			-1,
			completed_status, 
			project.issues.find_all_by_status_id(completed_status.id, :include => [:assigned_to])
		);
		
		subpanes = Hash.new	
		subpanes["development-ongoing"] = ongoing_pane
		subpanes["development-done"] = done_pane
		development = Multipane.new("Development", 4, subpanes)
		panes["development"] = development
		
		#TESTING
		test_status = IssueStatus.find_by_name("Test")
		test_pane = Pane.new(
			"Testing",
			3,
			test_status,
			project.issues.find_all_by_status_id(test_status.id, :include => [:assigned_to])
		);
		panes["test"] = test_pane
		
		# DEPLOYED
		deployed_status = IssueStatus.find_by_name("Resolved")
		deploy_pane = Pane.new(
			"Deployed",
			-1,
			deployed_status,
			project.issues.find_all_by_status_id(deployed_status.id, :include => [:assigned_to])
		);
		panes["deploy"] = deploy_pane
		
		return panes
	end
end
