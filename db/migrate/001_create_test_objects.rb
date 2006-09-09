class CreateTestObjects < ActiveRecord::Migration
  def self.up
    create_table :test_objects do |t|
      t.column :status, :string, :limit=>128, :null=>false
    end
  end

  def self.down
    drop_table :test_objects
  end
end
