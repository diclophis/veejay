class AddInfiniteSessionToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :facebook_user_id, :string
    add_column :people, :facebook_infinite_session, :string
  end

  def self.down
  end
end
