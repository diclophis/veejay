  module Ratings
    module ActionView
      def rating_stars(episode, person)
        rating = episode.rating
        css_names = %w(one two three four five)
        lis = ""
        css_names.each_with_index { |rating_name, value|
          value += 1
          css_class = rating_name
          if rating.to_i == value then
            css_class += " current_rating"
            css_style = "width: #{(rating * 30).to_i}px;"
          else
            css_style = ""
          end
          lis += content_tag("li", link_to(rating, rate_url(*episode.to_param + [value]), {:class => css_class}), {:class => css_class, :style => css_style})
        }
        content_tag("ul", lis, {:class => "rating"})
      end
    end
    
    module ActiveRecord
      def self.included(base)
        base.extend Ratings::ActiveRecord::ClassMethods
        class << base
          attr_accessor :has_rating_options
        end
      end
    
      module ClassMethods
        def has_ratings
          include Ratings::ActiveRecord::InstanceMethods
          self.has_rating_options = {
            :type => ::ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          }
          # associations
          has_many :ratings, :as => :ratable, :dependent => :destroy
          # named scopes
          named_scope :best_rated, :order => 'rating desc'
          named_scope :most_rated, :order => 'ratings_count desc'
        end
      end
    
      module InstanceMethods
        def rated?(owner)
          !find_rating_by_person(owner).nil?
        end
        def find_rating_by_person(owner)
          return nil unless owner
          self.ratings.find(:first, :conditions => {:rater_id => owner.id, :rater_type => owner.type.to_s})
        end
        def rating!
          Rating.average(:value_id, {
            :conditions => {
              :ratable_type => self.class.has_rating_options[:type],
              :ratable_id => self.id
            }
          })
        end
        def find_people_that_rated(options={})
          options = {
            :limit => 10,
            :conditions => ["ratings.ratable_type = ? and ratings.ratable_id = ?", self.class.has_rating_options[:type], self.id],
            :include => :ratings
          }.merge(options)

          Person.paginate(options)
        end
      end
    end
  end
      
ActionView::Base.send :include, Ratings::ActionView
ActiveRecord::Base.send :include, Ratings::ActiveRecord
