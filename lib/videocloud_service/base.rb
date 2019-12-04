module VideocloudService
  class Base
    attr_reader :api_service
    include ActiveModel::Validations

    def initialize(authParameters = {})
      @api_service = VideocloudService::Api.instance(authParameters)
      @account_id = authParameters['AccountId'] || ENV['BRIGHTCOVE_ACCOUNT_ID']
    end

    def add_error(e)
      # puts e.backtrace
      error = JSON.parse(e.message) rescue e
      errors.add(:base, error)
      @result = { :error => e.message }
    end

    def stringify_keys(hash)
      hash.each { |key, value|
        hash[key] = stringify_keys(value) if value.class == Hash
        hash[key] = value.map { |val| 
          val.class == Hash ? stringify_keys(val) : val
        } if value.class == Array
      }
      hash.transform_keys { |key, val|
        key.to_s rescue key 
      }
    end
  
    def stringify_params(params)
      @params = stringify_keys(params)
    end
    
  end
end
