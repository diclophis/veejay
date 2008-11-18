#

module ActiveRecord
  module Validations
    module ClassMethods
      def validates_as_uri (*params)
        configuration = {}
        validates_each(params, configuration) { |record, field, value|
          next if value.nil? or value.empty?
          begin
            uri = URI.parse(value)
            logger.debug(uri.inspect)
            #record.errors.add(field, 'Only HTTP protocol addresses can be used') unless uri.is_a?(URI::HTTP)
            raise URI::InvalidURIError.new unless uri.is_a?(URI::HTTP)
          rescue URI::InvalidURIError
            record.errors.add(field, "is not a valid URI")
          end
        }
      end
    end
  end
end
