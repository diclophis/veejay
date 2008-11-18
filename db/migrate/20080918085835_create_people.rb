class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.string :identity_url
      t.string :email
      t.string :nickname
      t.timestamps
    end
  end

  def self.down
    drop_table :people
  end
end
