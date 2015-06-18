# Aws.config.update({
# 	region: 'us-east-1',
# 	credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
# })

# s3 = Aws::S3::Resource.new
# S3_AVATAR_BUCKET = s3.bucket(ENV['S3_AVATAR_BUCKET'])
# #S3_AVATAR_THUMBNAIL_BUCKET = s3.bucket(ENV['S3_AVATAR_THUMBNAIL_BUCKET'])