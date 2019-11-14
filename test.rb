require_relative './lib/videocloud_service.rb'

$params = {
  "title_en"=>"episode",
  "assets"=>{
    "Go Sample.webp"=>{
      "name"=>"Go",
      "type"=>"long_form_video",
      "lang"=>"en"
    },
     "0"=>{
     "url"=>"https://homepages.cae.wisc.edu/~ece533/images/airplane.png",
     "type"=>"thumbnail",
     "lang"=>"en",
     },
  },
  "start_date"=>"2018-08-29 09:19:38",
  "end_date"=>"2018-10-05 09:19:41",
  "restricted"=>"true",
  "exclude_countries"=>"false",
  "countries"=>[
    "IN",
    "ID",
    "SG"
  ]
}

$authParameters = {
  'CliendId' =>  'ff1aea56-257d-4e54-af6a-7262580a0dd0', 
  'CliendSecret' => 'BpOBoEbp0bBzIulEaAnGNrtfYl9uDkBOeSex9xs9IBHyvLCzpxZQK75zO_mVE2DQor_bSUCjSYQSgjYlqWxk4A', 
  'AccountId' =>  '6098995841001'
}

def ingest_video
  service = VideocloudService::Video.new($authParameters)
  service.create_videos($params)
  puts 'Creation errors = ', service.errors.full_messages 
  puts 'service.brightcove_video = ', service.brightcove_video
  params1 = {
    "master_url"=>"http://learning-services-media.brightcove.com/videos/mp4/greatblueheron.mp4",
    "poster_url"=>"http://learning-services-media.brightcove.com/images/celtic-lullaby-large.png",
    "thumbnail_url"=>"http://learning-services-media.brightcove.com/images/celtic-lullaby-large.png",
    "video_id"=>service.brightcove_video['id']
  }
  ingest_service = VideocloudService::Ingest.new($authParameters)
  ingest_service.ingest_video(params1)
  puts 'result = ', ingest_service.result
  puts 'Ingestion errors = ', ingest_service.errors.full_messages
  service.brightcove_video["id"]
end

def get_videos(params = {})
  puts ''
  puts "********  get_videos *********", params
  service = VideocloudService::Video.new($authParameters)
  service.get_videos(params)
  puts service.result
end

def delete_video(videoId)
  service = VideocloudService::Video.new($authParameters)
  service.delete_video({'videoId' => videoId})
end

def get_videos_by_id(params)
  puts "********  get_videos_by_id *********"
  service = VideocloudService::Video.new($authParameters)
  service.get_videos_by_ids(params)
  puts service.result
end

def get_video_asset(params)
  puts ''
  puts "********  get_video_asset *********"
  service = VideocloudService::Video.new($authParameters)
  service.get_video_assets(params)
  puts service.result
end

def get_video_count(params)
  puts ''
  puts "********  get_video_count *********",params
  service = VideocloudService::Video.new($authParameters)
  service.get_video_count(params)
  puts service.result
end

def get_video(params)
  puts ''
  puts "********  get_video *********",params
  service = VideocloudService::Video.new($authParameters)
  service.get_video(params)
  puts service.result
end

def get_profiles
  puts ''
  puts "********  get_profiles *********"
  service = VideocloudService::Profile.new($authParameters)
  service.get_all_ingested_profiles
  puts service.result
end

def get_profile(params)
  puts ''
  puts "********  get_profile *********",params
  service = VideocloudService::Profile.new($authParameters)
  service.get_ingested_profile
  puts service.result
end

def main
  get_videos
  id = ingest_video
  delete_video(id)
  get_videos({'limit' => 10})
  get_videos_by_id({ 'videoIds' => ['6101921474001', '6101384271001'] })
  get_video_asset({'videoId' => '6101851149001', 'assetType' => 'renditions'})
  get_video_asset({'videoId' => '6101851149001', 'assetType' => 'hls_manifest'})
  get_video_count({})
  get_video({'videoId' => '6101917651001'})
  get_profiles
end

main