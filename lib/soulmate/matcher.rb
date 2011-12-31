module Soulmate

  class Matcher < Base

    def matches_for_term(term, options = {})
      options = { :limit => 5, :cache => true }.merge(options)
      
      words = normalize(term).split(' ').reject do |w|
        w.size < MIN_COMPLETE or STOP_WORDS.include?(w)
      end.sort

      return [] if words.empty?

      cachekey = "#{cachebase}:" + words.join('|')
      puts cachekey
      if !options[:cache] || !Soulmate.redis.exists(cachekey)
        interkeys = words.map { |w| "#{base}:#{w}" }
        Soulmate.redis.zunionstore(cachekey, interkeys)
        Soulmate.redis.expire(cachekey, 10 * 60) # expire after 10 minutes
      end
      puts cachekey
      
      ids = Soulmate.redis.zrevrange(cachekey, 0, options[:limit] - 1)
      if ids.size > 0
        puts ids
        results = Soulmate.redis.hmget(database, *ids)
        results = results.reject{ |r| r.nil? } # handle cached results for ids which have since been deleted
        results.map { |r| MultiJson.decode(r) }
      else
        []
      end
    end
  end
end