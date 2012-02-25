# -*- encoding : utf-8 -*-
class RedisId
  
  #get new id for model
  def self.get model
    raise ArgumentError, "Need to specify model name!" unless model
    #every time it's called, increment id to new one and return it
    return Database.redis.incr("redis_ids:#{model.downcase}") 
  end

  #get new id for model
  def self.set model, last_id
    raise ArgumentError, "Need to specify model name!" unless model
    raise ArgumentError, "Need to specify last_id!" unless last_id || last_id.is_a?(Fixnum)
    #every time it's called, increment id to new one and return it
    return Database.redis.set("redis_ids:#{model.downcase}", last_id)
  end
  
end