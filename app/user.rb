# -*- encoding : utf-8 -*-
class User
  
  REDIS_MODEL_CONF = {
    :fields => {
      :name => :to_s,
      :email => :to_s,
      :password => :to_s,
      :salt => :to_s,
      :reset_token => :to_s,
    }, 
    :required => [:email,:password],
    :redis_key => [:email],
    :redis_aliases => {
      :reset_token => [:reset_token]
    }
  }
  include RedisModel
  initialize_redis_model_methods REDIS_MODEL_CONF
  include UserAuthModel


  def get_name 
    pp self.name
    pp self.email
    if self.name && self.name.size > 0
      self.name
    else
      self.email
    end
  end
end