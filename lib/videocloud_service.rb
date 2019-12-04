require 'active_model'
require 'active_support'
require 'active_support/time'
require_relative './videocloud_service/ingest'
require_relative './videocloud_service/video'
require_relative './videocloud_service/profile'
require 'http'

module VideocloudService
  class Api

    OAUTH_ENDPOINT = 'https://oauth.brightcove.com/v4/access_token'
    CMS_API_ROOT = 'https://cms.api.brightcove.com/v1/accounts'
    INGEST_API_ROOT = 'https://ingestion.api.brightcove.com/v1/accounts'
    PER_PAGE = 100

    def self.instance(authParameters = {})
      @@instance ||= new(authParameters)
    end

    def initialize(authParameters = {})
      @client_id = authParameters['CliendId'] || ENV['BRIGHTCOVE_CLIENT_ID']
      @client_secret = authParameters['CliendSecret'] || ENV['BRIGHTCOVE_CLIENT_SECRET']
      if [@client_id, @client_secret].any? { |c| c.to_s.empty? }
        raise StandardError, 'Missing Brightcove API credentials'
      end
      set_token
    end

    def perform_action(request_type, url, params = {}, query = {})
      set_token if @token_expires < Time.now
      @request_type = request_type
      @url = url
      puts '@url = ',@url
      query_prams = query.map{|k,v| "#{k}=#{v}"}.join('&')
      @url += "?#{query_prams}" unless query_prams.empty?
      @params = params
      response = make_request
      return response.parse if [200, 201].include? response.code
      raise StandardError, response.to_s
    end

    def make_request
      case @request_type
      when 'post'
        http.post(@url, body: @params)
      when 'get'
        http.get(@url)
      when 'patch'
        http.patch(@url, body: @params)
      when 'delete'
        http.delete(@url)
      end
    end

    def http
      HTTP.headers('Authorization' => "Bearer #{@token}", 'Content-Type' => 'application/json')
    end

    private

    def set_token
      response = auth_request      
      # token_response = auth_request.parse
      token_response = response.parse
      return update_token(token_response) if response.status == 200
      raise StandardError, token_response.fetch('error_description')
    end

    def update_token(token_response)
      @token = token_response.fetch('access_token')
      @token_expires = Time.now + token_response.fetch('expires_in')
    end

    def auth_request
      HTTP.basic_auth(user: @client_id, pass: @client_secret)
          .post(OAUTH_ENDPOINT,
                form: { grant_type: 'client_credentials' })
    end

    def raise_account_error
      raise StandardError, 'Token valid but not for the given account_id'
    end
  end
end
