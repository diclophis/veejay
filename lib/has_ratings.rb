  module Ratings
    module ActionView
      def rating_stars(episode, person)
        rating = episode.rating
        css_names = %w(one two three four five)
        lis = ""
        css_names.each_with_index { |rating_name, value|
          value += 1
          css_class = rating_name
          logger.debug(rating_name)
          logger.debug(rating)
          logger.debug(value)
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
#        css_rating = css_names[rating.to_i]
#        diff = ('%.1f' % (rating.to_f - rating.to_i)).to_f
#        if (0.1..0.5).include?(diff)
#          css_rating << '-half'
#        elsif (0.6..0.9).include?(diff)
#          css_rating = css_names[rating.to_i + 1]
#        end
        
=begin
        if object.rated?(person)
          %(
            <ul class="rating #{css_rating} rated">
              <li class="one"><span>1</span></li>
              <li class="two"><span>2</span></li>
              <li class="three"><span>3</span></li>
              <li class="four"><span>4</span></li>
              <li class="five"><span>5</span></li>
            </ul>
          )
        else
=end
=begin
          %(
            <ul class="rating #{css_rating}">
              <li class="one"><a class="one" href="#{rate_url(*episode.to_param + [1])}" title="1 Star" rel="no-follow">1</a></li>
              <li class="two"><a class="two" href="#{rate_url(*episode.to_param + [2])}" title="2 Stars" rel="no-follow">2</a></li>
              <li class="three current_rating" style="width: 105px; "><a class="three" href="#{rate_url(*episode.to_param + [3])}" title="3 Stars" rel="no-follow">3</a></li>
              <li class="four"><a class="four" href="#{rate_url(*episode.to_param + [4])}" title="4 Stars" rel="no-follow">4</a></li>
              <li class="five"><a class="five" href="#{rate_url(*episode.to_param + [5])}" title="5 Stars" rel="no-follow">5</a></li>
            </ul>
          )
#        end
      end
=end
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
        def rating
          Rating.average(:value_id, {
            :conditions => {
              :ratable_type => self.class.has_rating_options[:type],
              :ratable_id => self.id
            }
          })
        end
        #def rate(options)
        #  options[:person_id] = options.delete(:person).id if options[:person]
        #  self.ratings.create(options)
        #end
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
