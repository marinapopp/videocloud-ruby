module Factory
  def createVideoRequestSample 
    {
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
  end

  def createVideoResponseSample
    [{
      :filename=>"Go Sample.webp",
      :presigned_url=>"url",
      :request_url=>nil,
      :video_id=>123
    }]
  end

  def simbolizedHash
    {:a=>1, :b=>[2,3], :c=>{:l=>1}, :d=>[:a=>1, :b=>2]} 
  end

  def stringifiedHash
    {'a'=>1, 'b'=>[2,3], 'c'=>{'l'=>1}, 'd'=>['a'=>1, 'b'=>2]}
  end

  def getVideosResponse
    {
      "id"=>"1", 
      "account_id"=>"2", 
      "ad_keys"=>nil, 
      "clip_source_video_id"=>nil, 
      "complete"=>true, 
      "created_at"=>"2019-11-08T14:42:47.685Z", 
      "created_by"=>{
        "type"=>"api_key", 
        "email"=>"email"
      }
    }
  end

  def ingestParams
    {
      "master_url"=>"http://master_url",
      "poster_url"=>"http://poster_url",
      "thumbnail_url"=>"http://thumbnail_url",
      "video_id"=>1
    }
  end

  def ingestRequestParams
    {
      "master"=>{ "url"=>"http://master_url" },
      "poster"=>{ "url"=>"http://poster_url" },
      "thumbnail"=>{ "url"=>"http://thumbnail_url" }
    }
  end
end