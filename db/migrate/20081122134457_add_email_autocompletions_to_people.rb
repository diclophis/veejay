class AddEmailAutocompletionsToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :email_autocompletions, :text, :default => nil
  end

  def self.down
  end
end
