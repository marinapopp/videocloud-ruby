require_relative 'base'
require 'aws-sdk-s3'

module VideocloudService
  class Profile < Base
    attr_reader :result, :params

    def get_all_ingested_profiles
      @result = @api_service.perform_action('get', 'profiles');
    rescue StandardError => e
      add_error(e)
    end

    def get_ingested_profile(params)
      stringify_params(params)
      @result = @api_service.perform_action('get', "profiles/#{profile_id}");
    rescue StandardError => e
      add_error(e)
    end

    private

    def profile_id
      profileId = params['profileId']
      unless profileId
        raise StandardError, 'Missing profileId'
      end
      profileId
    end
    
  end
end
