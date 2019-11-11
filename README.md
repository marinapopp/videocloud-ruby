# VideocloudService

Ruby wrapper for creating videos and doing ingestion on brightcove

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'videocloud_service'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install videocloud_service

## Usage

Gem expects following environment variable to be set correctly:
```
ENV['BRIGHTCOVE_CLIENT_ID']
ENV['BRIGHTCOVE_CLIENT_SECRET']
ENV['BRIGHTCOVE_ACCOUNT_ID']
```

### Creating video on brightcove

```
authParameters = {
  'CliendId' =>  'XXXXXXXXXXXX', 
  'CliendSecret' => 'XXXXXXXXXXXX', 
  'AccountId' =>  'XXXXXXXXXXXX'
}
service = VideocloudService::Video.new(authParameters)
service.create_videos(params)
service.result # get result
service.errors # get errors
```

Sample params:
```
{
  'brightcove_reference_id'=>'FRIENDSS02213',
  'title_en'=>'episode',
  'assets'=>{
    'Go Sample.webp'=>{
      'name'=>'Go', \\ indicates file to be uploaded
      'type'=>'long_form_video',
      'lang'=>'en'
    },
     '0'=>{
     'url'=>'https://homepages.cae.wisc.edu/~ece533/images/airplane.png', \\ indicates url is already present
     'type'=>'thumbnail',
     'lang'=>'en'
     }
  },
  'start_date'=>'2018-08-29 09:19:38',
  'end_date'=>'2018-10-05 09:19:41',
  'restricted'=>'true',
  'exclude_countries'=>'false',
  'countries'=>[
    'IN',
    'ID',
    'SG'
  ]
}
```
Response will be array object.

For each file to be uploaded there will be object in response

object consist of following keys:
```
1. video_id: brightcove video id
2. presigned_url: url on which file should be uploaded
3. request_url: ingestion video url
4. filename: filename
```

### Ingesting video

```
service = VideocloudService::Ingest.new(authParameters)
service.ingest_video(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
  'text_tracks'=>{
    '0'=>{
      'url'=>'https://ingestion-upload-production.s3.amazonaws.com/578454510 1001/5832591619001/757ca3c3-a99f-487c-85bf-1badec004cd3/Tomb.Raider.2018.BluRay.720p.x264.DTS-HDC.srt.vtt',
      'lang'=>'en'
    }
  },
  'master_url'=>'https://ingestion-upload-production.s3.amazonaws.com/5784545101001/58325916 19001/9c96277a-69cb-446c-b3ee-6f728662ca92/Go%2520Sample.webp',
  'poster_url'=>'https://ingestion-upload -production.s3.amazonaws.com/5784545101001/5832591619001/350a7d28-9eaf-4ff3-907d-7673ab3e8a24/Sea_LionFish_ poster.png',
  'thumbnail_url'=>'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
  'video_id'=>'20398234619001'
}
```

### Getting videos (with optional filter)

```
service = VideocloudService::Video.new($authParameters)
service.get_videos(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'limit' => 20, 
  'offset' => 1, 
  'sort' => 'published_at',
  'q' => 'q=%2Btags%3Abird'
}
```

### Getting videos by id 

```
service = VideocloudService::Video.new($authParameters)
service.get_videos_by_ids(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'videoIds' => [1,2,3]
}
```

### Getting video assets

```
service = VideocloudService::Video.new($authParameters)
service.get_video_assets(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'videoId' => 1, (required)
  'assetType' => 'dynamic_renditions' (optional)
}
```

### Creation video asset

```
service = VideocloudService::Video.new($authParameters)
service.create_video_asset(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'videoId' => 1,
  'assetType' => 'hls_manifest'
}
```

### Update video

```
service = VideocloudService::Video.new($authParameters)
service.update_video(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'ad_keys': ' \'adKeys\Sample params:: \'category=sports&live=true\'',
  'cue_points': [{ }],
  'custom_fields': 
  {
    'property1': 'string',
    'property2': 'string'

  },
  'description': 'Herring gull on a wharf in Boston',
  'drm_disabled': true,
  'economics': 'AD_SUPPORTED',
  'geo': 
  {
    'countries': [],
    'exclude_countries': true,
    'restricted': true
  },
  'link': 
  {
      'text': 'string',
      'url': 'string'
  },
  'live': { },
  'long_description': 'Herring Gull near Fort Point Channel in Boston, MA, USA. 2019-04-25.',
  'name': 'Laughing Gull',
  'offline_enabled': true,
  'projection': 'equirectangular',
  'reference_id': 'laughing_gull_2019_04_25',
  'schedule': 
  {
      'ends_at': '2020-05-20T20:41:07.689Z',
      'starts_at': '2019-05-20T20:41:07.689Z'
  },
  'state': 'ACTIVE',
  'tags': 
  [
      'birds',
      'sea'
  ],
  'text_tracks': [{ }]
}
```

### Get video count

```
service = VideocloudService::Video.new($authParameters)
service.get_video_count(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'sort' => 'published_at',
  'q' => 'q=%2Btags%3Abird'
}
```

### Get video

```
service = VideocloudService::Video.new($authParameters)
service.get_video(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'videoId' => 1
}
```

### Delete video

```
service = VideocloudService::Video.new($authParameters)
service.delete_video(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'videoId' => 1
}
```

### Get all ingested profiles

```
service = VideocloudService::Profile.new($authParameters)
service.get_all_ingested_profiles
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'videoId' => 1
}
```

### Get ingested profile

```
service = VideocloudService::Profile.new($authParameters)
service.get_ingested_profile(params)
service.result # get result
service.errors # get errors
```
Sample params:
```
{
  'profileId' => 1
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marinapopp/videocloud_service. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the VideocloudService project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/marinapopp/videocloud_service/blob/master/CODE_OF_CONDUCT.md).
