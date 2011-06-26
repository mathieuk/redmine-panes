class UpdatePanes < ActiveRecord::Migration
	def self.up
		change_table :panes do |t|
		  t.integer :project_id
		end
	end
	
	def self.down
		remove_column :panes, :project_id
	end
end
