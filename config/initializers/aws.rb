AWS.config(access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
           secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] )

S3_AVATAR_BUCKET = AWS::S3.new.buckets[ENV['S3_AVATAR_BUCKET']]
S3_AVATAR_THUMBNAIL_BUCKET = AWS::S3.new.buckets[ENV['S3_AVATAR_THUMBNAIL_BUCKET']]