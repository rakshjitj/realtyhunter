# # config/initializers/refile.rb
# require "refile/s3"

# aws = {
# 	region: 'us-east-1',
#   access_key_id: ENV['AWS_ACCESS_KEY_ID'],
#   secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
#   bucket: ENV['S3_AVATAR_BUCKET'],
# }
# Refile.cache = Refile::S3.new(prefix: "cache", **aws)
# Refile.store = Refile::S3.new(prefix: "store", **aws)

# # TODO: why does this break on dev?
# #Refile.host = "//" + ENV['CLOUDFRONT_ENDPOINT']
# #Refile.host = "//your-dist-url.cloudfront.net"