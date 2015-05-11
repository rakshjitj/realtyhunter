require "refile/backend/s3"

aws = {
  access_key_id: "AKIAJL2IVCUIEPN4M27Q",
  secret_access_key: "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",
  bucket: "dev-realty-monster-avatars",
}
Refile.cache = Refile::Backend::S3.new(prefix: "cache", **aws)
Refile.store = Refile::Backend::S3.new(prefix: "store", **aws)

#Refile.host = "//your-dist-url.cloudfront.net"