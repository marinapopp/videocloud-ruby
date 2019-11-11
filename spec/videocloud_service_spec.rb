require_relative './factory'

RSpec.describe VideocloudService do
  let(:authParameters) { {
    'CliendId' =>  'someCliendId', 
    'CliendSecret' => 'someCliendSecret',
    'AccountId' =>  'someAccountId'
  } }
  let(:video_object) { VideocloudService::Video.new(authParameters) }
  let(:ingest_object) { VideocloudService::Ingest.new(authParameters) }
  let(:profile_object) { VideocloudService::Profile.new(authParameters) }
  
  it 'has a version number' do
    expect(VideocloudService::VERSION).not_to be nil
  end

  describe 'Video' do
    before(:each) do
      allow_any_instance_of(VideocloudService::Api).to receive(:set_token).and_return(true)
      allow_any_instance_of(Aws::S3::Presigner).to receive(:presigned_url).and_return('url')
    end

    describe '#stringify_params' do
      it 'returns stringified hash' do
        allow_any_instance_of(VideocloudService::Api).to receive(:set_token).and_return(true)
        video_object.stringify_params(simbolizedHash)
        expect(video_object.params).to eq (stringifiedHash)
      end
    end

    describe '#create_videos' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return({'id'=>123})
      end

      it 'gets error as a result' do
        video_object.create_videos({})
        expect(video_object.result[:error]).to eq ('long_form_video required')
      end

      it 'gets correct result' do
        video_object.create_videos(createVideoRequestSample)
        expect(video_object.result).to eq (createVideoResponseSample)
      end

      it 'calls method valid?' do
        expect(video_object).to receive(:valid?)
        video_object.create_videos(createVideoRequestSample)
      end

      it 'calls method create_videos_on_brightcove' do
        expect(video_object).to receive(:create_videos_on_brightcove)
        video_object.create_videos(createVideoRequestSample)
      end

      it 'calls method set_result' do
        expect(video_object).to receive(:set_result)
        video_object.create_videos(createVideoRequestSample)
      end
    end

    describe '#get_videos' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(getVideosResponse)
      end
      
      it 'calls perform_action with given query' do
        query = {'limit' => 1}
        expect(video_object.api_service).to receive(:perform_action).with('get', 'videos', {}, query)
        video_object.get_videos(query)
      end

      it 'gets correct response' do
        video_object.get_videos
        expect(video_object.result).to eq (getVideosResponse)
      end

      it 'query has right keys' do
        query = { 'limit' => 1, 'blabla' => 2, 'q' => 3, 'offset' => 4, 'sort' => 5 }
        query_res = query.slice('limit', 'q', 'offset', 'sort')
        expect(video_object.api_service).to receive(:perform_action).with('get', 'videos', {}, query_res)
        video_object.get_videos(query)
      end
    end

    describe '#get_videos_by_ids' do
      
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(getVideosResponse)
      end
      it 'calls perform_action without ids if not given' do
        expect(video_object.api_service).to receive(:perform_action).with('get', 'videos/')
        video_object.get_videos_by_ids()
      end

      it 'calls perform_action with given ids' do
        expect(video_object.api_service).to receive(:perform_action).with('get', 'videos/1,2,3')
        video_object.get_videos_by_ids({'videoIds': [1,2,3]})
      end

      it 'gets correct response' do
        video_object.get_videos_by_ids({'videoIds': [1]})
        expect(video_object.result).to eq (getVideosResponse)
      end
    end

    describe '#get_video_assets' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(getVideosResponse)
      end

      it 'gets error as a result if videoId not given' do
        video_object.get_video_assets()
        expect(video_object.result[:error]).to eq ('Missing videoId')
      end

      it 'gets error as a result if assetType not given' do
        video_object.get_video_assets({ 'videoId': 1 })
        expect(video_object.result[:error]).to eq ('Missing assetType')
      end
      
      it 'calls perform_action with correct url' do
        expect(video_object.api_service).to receive(:perform_action).with('get', 'videos/1/assets/asset_type')
        video_object.get_video_assets({ 'videoId': 1,  'assetType': 'asset_type' })
      end

      it 'gets correct response' do
        video_object.get_video_assets({ 'videoId': 1,  'assetType': 'asset_type' })
        expect(video_object.result).to eq (getVideosResponse)
      end
    end

    describe '#create_video_asset' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(1)
      end

      it 'gets error as a result if videoId not given' do
        video_object.create_video_asset()
        expect(video_object.result[:error]).to eq ('Missing videoId')
      end

      it 'gets error as a result if assetType not given' do
        video_object.create_video_asset({ 'videoId': 1 })
        expect(video_object.result[:error]).to eq ('Missing assetType')
      end
      
      it 'calls perform_action with correct url' do
        expect(video_object.api_service).to receive(:perform_action).with('post', 'videos/1/assets/asset_type', { 'a': 1 }.to_json)
        video_object.create_video_asset({ 'videoId': 1,  'assetType': 'asset_type' }, { 'a': 1 })
      end

      it 'gets correct response' do
        video_object.create_video_asset({ 'videoId': 1,  'assetType': 'asset_type' })
        expect(video_object.result).to eq (1) 
      end
    end

    describe '#update_video' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(1)
      end

      it 'gets error as a result if videoId not given' do
        video_object.update_video()
        expect(video_object.result[:error]).to eq ('Missing videoId')
      end
      
      it 'calls perform_action with correct url' do
        expect(video_object.api_service).to receive(:perform_action).with('patch', 'videos/1', { 'a': 1 }.to_json)
        video_object.update_video({ 'videoId': 1 }, { 'a': 1 })
      end

      it 'gets correct response' do
        video_object.update_video({ 'videoId': 1 })
        expect(video_object.result).to eq (1) 
      end
    end

    describe '#get_video_count' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(1)
      end
      
      it 'calls perform_action with correct url' do
        query = { 'blabla': 2, 'q': 3 }
        query_res = query.slice('q')
        expect(video_object.api_service).to receive(:perform_action).with('get', 'counts/videos', {}, query_res)
        video_object.get_video_count(query)
      end

      it 'gets correct response' do
        video_object.get_video_count({ 'q': 1})
        expect(video_object.result).to eq (1) 
      end
    end

    describe '#get_video' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(1)
      end

      it 'gets error as a result if videoId not given' do
        video_object.get_video()
        expect(video_object.result[:error]).to eq ('Missing videoId')
      end
      
      it 'calls perform_action with correct url' do
        expect(video_object.api_service).to receive(:perform_action).with('get', 'videos/1', {})
        video_object.get_video({ 'videoId': 1 })
      end

      it 'gets correct response' do
        video_object.get_video({ 'videoId': 1 })
        expect(video_object.result).to eq (1) 
      end
    end

    describe '#delete_video' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(1)
      end

      it 'gets error as a result if videoId not given' do
        video_object.delete_video()
        expect(video_object.result[:error]).to eq ('Missing videoId')
      end
      
      it 'calls perform_action with correct url' do
        expect(video_object.api_service).to receive(:perform_action).with('delete', 'videos/1', {})
        video_object.delete_video({ 'videoId': 1 })
      end

      it 'gets correct response' do
        video_object.delete_video({ 'videoId': 1 })
        expect(video_object.result).to eq (1) 
      end
    end
  end

  describe 'Ingest' do
    before(:each) do
      allow_any_instance_of(VideocloudService::Api).to receive(:set_token).and_return(true)
    end

    describe '#ingest_video' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return(1)
      end

      it 'gets error as a result if videoId not given' do
        params = ingestParams.slice('video_id', 'poster_url', 'thumbnail_url')
        ingest_object.ingest_video(params)
        expect(ingest_object.result[:error]).to eq ('invalid params')
      end
      
      it 'calls perform_action with correct url' do
        expect(ingest_object.api_service).to receive(:perform_action).with('post', 'videos/1/ingest-requests', ingestRequestParams.to_json)
        ingest_object.ingest_video(ingestParams)
      end

      it 'gets correct response' do
        ingest_object.ingest_video(ingestParams)
        expect(ingest_object.result).to eq (1) 
      end
    end
  end

  describe 'Profile' do
    before(:each) do
      allow_any_instance_of(VideocloudService::Api).to receive(:set_token).and_return(true)
    end

    describe '#get_all_ingested_profiles' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return([])
      end
      
      it 'calls perform_action with correct url' do
        expect(ingest_object.api_service).to receive(:perform_action).with('get', 'profiles')
        profile_object.get_all_ingested_profiles()
      end

      it 'gets correct response' do
        profile_object.get_all_ingested_profiles()
        expect(profile_object.result).to eq ([]) 
      end
    end

    describe '#get_ingested_profile' do
      before(:each) do
        allow_any_instance_of(VideocloudService::Api).to receive(:perform_action).and_return({})
      end

      it 'gets error as a result if profileId not given' do
        profile_object.get_ingested_profile({})
        expect(profile_object.result[:error]).to eq ('Missing profileId')
      end
      
      it 'calls perform_action with correct url' do
        expect(profile_object.api_service).to receive(:perform_action).with('get', 'profiles/1')
        profile_object.get_ingested_profile({ 'profileId': 1 })
      end

      it 'gets correct response' do
        profile_object.get_ingested_profile({ 'profileId': 1 })
        expect(profile_object.result).to eq ({}) 
      end
    end

  end
end
