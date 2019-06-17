module ArticlesHelper
    def fetch_articles_redis
        articles = $redis.get("articles")  #This line requests redis-server to accepts any value associate with articles key
        if articles.nil?  #this condition will executes if any articles not available on redis server
            articles = Article.all.to_json   
            $redis.set("articles",articles)
            $redis.expire("articles",2.minutes.to_i)
        end
        JSON.load articles #This will converts JSON data to Ruby Hash
    end
end