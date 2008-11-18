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
