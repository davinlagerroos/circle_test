# uri = URI.parse(ENV["REDISTOGO_URL"])
# $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/" )
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)