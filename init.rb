require 'redmine'

Redmine::Plugin.register :redmine_kanban do
  name 'Redmine Kanban plugin'
  author 'Mathieu Kooiman'
  description 'This is a plugin for Redmine Kanban'
  version '0.0.1'
  url 'http://www.mollie.nl/'
  author_url 'http://www.mollie.nl/'
end

Redmine::Plugin.register :redmine_kanban do
	permission :polls, {:kanban => [:index]}, :public => true
	menu :project_menu, :kanban, { :controller => 'kanban', :action => 'index' }, :caption => 'Kanban', :after => :activity, :param => :project_id
	
	project_module :kanban do
		permission :view_board, :kanban => :index
		permission :update_board, :kanban => :update_pane
		permission :edit_issue, :kanban => :edit_issue
		permission :configure, :kanban => :configure
	end
end


