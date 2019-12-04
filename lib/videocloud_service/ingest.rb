require_relative 'base'

module VideocloudService
  class Ingest < Base
    attr_reader :result, :params
    validate :validate_params

    def initialize(authParameters = {})
      super
      @base_url = "#{VideocloudService::Api::CMS_API_ROOT}/#{@account_id}"
    end

    def ingest_video(params)
      stringify_params(params)
      valid? && ingest_video_and_assets
    end

    private

    def validate_params
      return true if params['video_id'].present? && params['master_url'].present?
      errors.add(:base, 'invalid params, missing video_id or master_url')
      @result = { error: 'invalid params' }
    end

    # rubocop:disable Metrics/AbcSize
    def ingest_params
      @ingest_params = { master: master_record }
      @ingest_params[:text_tracks] = text_tracks if params['text_tracks']
      @ingest_params[:audio_tracks] = { masters: audio_tracks } if params['audio_tracks']
      @ingest_params[:poster] = { url: params['poster_url'] } if params['poster_url']
      @ingest_params[:thumbnail] = { url: params['thumbnail_url'] } if params['thumbnail_url']
      @ingest_params
    end
    # rubocop:enable Metrics/AbcSize

    def master_record
      rec = { url: params['master_url'] }
      return rec if params['audio_tracks'].blank?
      rec[:audio_tracks] = audio_lang.uniq
      rec
    end

    def audio_lang
      params['audio_tracks'].collect do |_, tracks|
        { language: tracks['lang'] }
      end
    end

    def text_tracks
      params['text_tracks'].collect do |_, tracks|
        {
          url: tracks['url'],
          srclang: tracks['lang'],
          kind: 'subtitles'
        }
      end
    end

    def audio_tracks
      params['audio_tracks'].collect do |_, tracks|
        {
          url: tracks['url'],
          language: tracks['lang'],
          variant: 'descriptive'
        }
      end
    end

    def ingest_video_and_assets
      url = "#{@base_url}/videos/#{params['video_id']}/ingest-requests"
      @result = @api_service.perform_action('post', url, ingest_params.to_json)
    rescue StandardError => e
      add_error(e.message)
    end
    
  end
end
