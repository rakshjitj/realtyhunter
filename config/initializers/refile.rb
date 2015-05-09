# config/initializers/refile.rb
require "refile/backend/s3"

aws = {
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  bucket: ENV['S3_AVATAR_BUCKET'],
}
Refile.cache = Refile::Backend::S3.new(prefix: "cache", **aws)
Refile.store = Refile::Backend::S3.new(prefix: "store", **aws)
Refile.host = "//d3o6a4fzhkel22.cloudfront.net"