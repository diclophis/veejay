class Friendship < ActiveRecord::Base

  belongs_to :friendshipped_by_me,   :foreign_key => "person_id",   :class_name => "Person"
  belongs_to :friendshipped_for_me,  :foreign_key => "friend_id", :class_name => "Person"

  # TODO: Add some friendly accessor methods here

end

