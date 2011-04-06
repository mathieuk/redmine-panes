class CreatePanes < ActiveRecord::Migration
  def self.up
    create_table :panes do |t|
      t.column :key, :string
      t.column :title, :string
      t.column :wip_limit, :integer
      t.column :parent_pane_id, :integer
      t.column :status_id, :integer
	  t.column :position, :integer
    end
  end

  def self.down
    drop_table :panes
  end
end
