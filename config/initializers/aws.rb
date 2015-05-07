#require 'aws-sdk'
#Aws.config.update({
#	region:            'us-east-1',
#  access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
#  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
#})
#s3 = Aws::S3::Resource.new
#S3_BUCKET = s3.bucket(ENV['S3_BUCKET'])

AWS.config(access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
           secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] )

S3_BUCKET = AWS::S3.new.buckets[ENV['S3_BUCKET']]