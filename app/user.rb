# -*- encoding : utf-8 -*-
class User
  
  attr_accessor :user_id, :name, :email, :password, :token, :reset_token
  
# Example object in REDIS
# redis key:        user:id:user_id             #for searching by id
#   hash structure:   user_id, name, email, password, token, reset_token
#
# redis alias key:  user:email:email            #for authentication
# redis alias key:  user:token:token            #for authentication
# redis alias key:  user:reset_token:token      #for authentication
   
   
   REDIS_MODEL_CONF = {
     :fields => { 
       :user_id => :to_i,
       :name => :to_s,
       :email => :to_s,
       :password => :to_s,
       :token => :to_s,
       :reset_token => :to_s
      }, 
      :required => [:user_id],
      :redis_key => [:user_id],
      :redis_aliases => {
        :token => [:token],
        :reset_token => [:reset_token],
      }
   }
   include RedisModel
   initialize_redis_model_methods REDIS_MODEL_CONF


end