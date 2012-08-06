# uri = URI.parse(ENV["REDISTOGO_URL"])
# $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

$redis = Redis.new(:host => 'localhost', :port => 6379)
