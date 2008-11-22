class CreateRedirects < ActiveRecord::Migration
  def self.up
    create_table :redirects do |t|
      t.string :permalink
      #/redirect/bob-to-something-else-for-diclophis
      t.integer :person_id
      t.text :nonce
      t.string :nonce_url
      t.string :default_url
      t.datetime :nonced_on
      t.datetime :expires_on
      t.timestamps
    end
  end

  def self.down
    drop_table :redirects
  end
end
