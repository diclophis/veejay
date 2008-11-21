class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities, :force => true do |t|
      t.boolean :public
      t.integer :item_id
      t.integer :person_id
      t.string :item_type
      t.timestamps
    end
    add_index "activities", ["item_id"], :name => "index_activities_on_item_id"
    add_index "activities", ["item_type"], :name => "index_activities_on_item_type"
    add_index "activities", ["person_id"], :name => "index_activities_on_person_id"
  end

  def self.down
    drop_table :activities
  end
end
