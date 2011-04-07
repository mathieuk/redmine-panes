class CreateTrackerConfigs < ActiveRecord::Migration
  def self.up
    create_table :tracker_configs do |t|
      t.column :project_id, :int
      t.column :tracker_type, :string
      t.column :tracker_id, :integer
      t.column :color, :string
    end
  end

  def self.down
    drop_table :tracker_configs
  end
end
