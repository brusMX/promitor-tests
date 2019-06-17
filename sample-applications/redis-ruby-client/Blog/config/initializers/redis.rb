
if ENV["REDIS_HOST"]
    host = ENV["REDIS_HOST"]
else 
    abort ("Error. Redis host is empty")
end
if ENV["REDIS_PASS"]
    pass = ENV["REDIS_PASS"]
else 
    abort ("Error. Redis host is empty")
end
$redis = Redis::Namespace.new("redis_with_rails", :redis => Redis.new(host: host, db: 0, password: pass))
