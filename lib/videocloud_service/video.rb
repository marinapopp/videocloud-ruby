require_relative 'base'
require 'aws-sdk-s3'

module VideocloudService
  class Video < Base
    attr_reader :result, :params, :brightcove_video
    validate :long_form_video
    
    def create_videos(params)
      stringify_params(params)
      valid? &&
        create_videos_on_brightcove &&
        set_result
    rescue StandardError => e
      add_error(e)
    end

    def get_videos(params = {})
      stringify_params(params)
      query = params.select { |k,v| ['limit', 'offset', 'sort', 'q'].include?(k) }
      @result = @api_service.perform_action('get', 'videos', {}, query);
    rescue StandardError => e
      add_error(e)
    end

    def get_videos_by_ids(params = {'videoIds': []})
      stringify_params(params)
      @result = @api_service.perform_action('get', "videos/#{@params['videoIds'].join(',')}");
    rescue StandardError => e
      add_error(e)
    end

    def get_video_assets(params = {})
      stringify_params(params)
      url = "videos/#{video_id}/assets"
      if assetType = @params['assetType']
        url += "/#{assetType}"
      end
      @result = @api_service.perform_action('get', url);
    rescue StandardError => e
      add_error(e)
    end

    def create_video_asset(params = {}, data = {})
      stringify_params(params)
      @result = @api_service.perform_action('post', "videos/#{video_id}/assets/#{asset_type}", data.to_json);
    rescue StandardError => e
      add_error(e)
    end

    def update_video(params = {}, data = {})
      stringify_params(params)
      @result = @api_service.perform_action('patch', "videos/#{video_id}", data.to_json);
    rescue StandardError => e
      add_error(e)
    end

    def get_video_count(params = {})
      query = params.select { |k,v| ['sort', 'q'].include?(k) }
      @result = @api_service.perform_action('get', 'counts/videos', {}, query);
    rescue StandardError => e
      add_error(e)
    end

    def get_video(params = {})
      stringify_params(params) 
      @result = @api_service.perform_action('get', "videos/#{video_id}", {});
    rescue StandardError => e
      add_error(e)
    end

    def delete_video(params = {})
      stringify_params(params)
      @result = @api_service.perform_action('delete', "videos/#{video_id}", {});
    rescue StandardError => e
      add_error(e)
    end

    private

    def video_id
      videoId = params['videoId']
      unless videoId
        raise StandardError, 'Missing videoId'
      end
      videoId
    end

    def asset_type
      assetType = params['assetType']
      unless assetType
        raise StandardError, 'Missing assetType'
      end
      assetType
    end

    def validate_video_id
      videoId = params['videoId']
      return true if videoId
      @result = { error: 'Missing videoId' }
      false
    end

    def long_form_video     
      return true if params['assets']&.values&.any? do |a|
        a['type'] == 'long_form_video'
      end
      errors.add(:base, 'long_form_video required')
      @result = { error: 'long_form_video required' }
    end

    def create_videos_on_brightcove
      @brightcove_video = @api_service.perform_action('post', 'videos', brightcove_video_params.to_json)
    end

    def brightcove_video_params
      video_params = { name: asset_title,
                       reference_id: params['brightcove_reference_id'] }
      video_params['geo'] = geo_params if params['restricted'] == 'true'
      video_params['schedule'] = schedule_params if date_params?
      video_params
    end

    def asset_title
      params['title_en'] || params['title_id']
    end

    def date_params?
      params['start_date'].present? || params['end_date'].present?
    end

    def geo_params
      {
        restricted: params['restricted'] == 'true',
        exclude_countries: params['exclude_countries'] == 'true',
        countries: params['countries'].reject(&:blank?).map(&:downcase)
      }
    end

    def schedule_params
      {
        starts_at: parsed_time(params['start_date']),
        ends_at: parsed_time(params['end_date'])
      }
    end

    def parsed_time(time)
      time && Time.parse(time).in_time_zone.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
    end

    def set_result
      @result = s3_urls
    end

    # rubocop:disable Metrics/AbcSize
    def s3_urls
      urls = []
      params['assets'].each do |filename, values|
        next if values['name'].blank?
        result = get_s3_url(brightcove_video['id'], filename)        
        urls.push(video_id: brightcove_video['id'],
                  presigned_url: signed_url(filename, result),
                  request_url: result['api_request_url'],
                  filename: filename)
      end
      urls
    end
    # rubocop:enable Metrics/AbcSize

    def signed_url(_filename, result)
      signer = Aws::S3::Presigner.new(client: s3_client(result))
      signer.presigned_url(
        :put_object,
        bucket: result['bucket'],
        key: result['object_key']
      )
    end

    def s3_client(result)
      Aws::S3::Client.new(
        region:               'us-east-1',
        access_key_id:        result['access_key_id'],
        secret_access_key:    result['secret_access_key'],
        session_token:        result['session_token']
      )
    end

    def get_s3_url(video_id, filename)
      @api_service.perform_action('get', "videos/#{video_id}/upload-urls/#{filename}");
    end
    
  end
end
