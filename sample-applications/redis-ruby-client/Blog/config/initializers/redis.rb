
if ENV["REDIS_HOST"]
    host = ENV["REDIS_HOST"]
else 
    print ("Error. Redis host is empty")
end
if ENV["REDIS_PASS"]
    pass = ENV["REDIS_PASS"]
else 
    print ("Error. Redis host is empty")
end

port = 6380
    
if ENV["REDIS_PORT"]
    port = ENV["REDIS_PORT"]
end 

$redis = Redis::Namespace.new("redis_with_rails", :redis => Redis.new(host: host, db: 0, port: port, password: pass))
