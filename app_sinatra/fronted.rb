# -*- encoding : utf-8 -*-
class AskmeSinatra < Sinatra::Base
  
  get '/is_alive' do
    content_type :json
    output = {:status => "ok", :message => "Oh yeah Baby! Askme is alive :-)", :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S") }
    return JSON.pretty_generate(output)
  end

  get '/' do
    erb :index
  end
  
end
