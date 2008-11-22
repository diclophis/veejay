#

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_as_email (*params)
        configuration = {}
        validates_each(params, configuration) { |record, field, value|
          next if value.nil? or value.empty?
          begin
            address = TMail::Address.parse(value)
            raise if address.domain.blank?
            raise unless address.domain.include?(".")
            URI.parse("http://#{address.domain}")
          rescue
            record.errors.add(field, "is not a valid")
          end
        }
      end
    end
  end
end

class EmailParser
  def self.parse (emails)
    good = []
    bad = []
    split_emails = emails.split(",")
    split_emails.each { |email|
      begin
        parsed = TMail::Address.parse(email)
        self.sanity_check(parsed)
        good << parsed
      rescue
        parts = email.split(" ")
        address = parts.slice!(-1)
        name = parts.join(" ")
        formatted = "\"#{name}\" <#{address}>"
        begin
          parsed = TMail::Address.parse(formatted)
          self.sanity_check(parsed)
          good << parsed
        rescue
          bad << email
        end
      end
    }
    [good, bad]
  end
  def self.sanity_check (address)
    raise if address.domain.blank?
    raise unless address.domain.include?(".")
    URI.parse("http://#{address.domain}")
  end
end
