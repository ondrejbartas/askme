# -*- encoding : utf-8 -*-
class AskmeSinatra < Sinatra::Base
  
  def render_output name = nil, items = nil
    content_type :json
    output = {:status => "ok", :message => "ok", :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S") }
    output[name] = items unless name.nil?
    return JSON.pretty_generate(output)
  end

#  Backbone.js routes implementation 
#  create → POST   /collection
#  read → GET   /collection[/id]
#  update → PUT   /collection/id -> in askme we are not updating (except user)
#  delete → DELETE   /collection/id -> in askme we are not deleting

  #Get all users
  get %r{/users(\z|/[\d]*)} do |id|
    id = get_id_from_url id
    #Code for getting messages goes there, it should be automatically search too
    items = []
    render_output "users", items
  end

  #Create user
  post "/users" do
    message_id = RedisID.get(:user)
    #Code for creating messsage goes there
    render_output
  end

  #Update user
  put "/users/:id" do |id|
    #Code for updating user goes there
    render_output
  end
  
  # --- for the elasticsearch
  # TODO: custom exception

  # get a message for the appropriate message id : curl -XGET http://127.0.0.1:9393/messages/1
  get "/messages/:id" do |id|
    result = MessageFindModel.new(:ids=>[id.to_i]).find
    
    render_output 'found_message', result[0]
  end

  # get message(s) (complex search query)
  get '/messages' do
    result = MessageFindModel.new(params).find
    
    render_output 'found_messages', result
  end

  # create a message
  post '/messages' do
    message = params.clone
    message['id'] = RedisID.get(:message)

    result = MessageCreateModel.new(message).save

    render_output 'saved_message', result
  end
  
  # ++rank : curl -XPUT http://127.0.0.1:9393/messages/1/rank/inc -d ''
  put "/messages/:id/rank/inc" do |id|
    msg = MessageUpdateModel.new(:ids=>[id.to_i])
    msg.message.rank += 1
    result = msg.update
    
    render_output 'updated_message', result
  end

  # --rank : curl -XPUT http://127.0.0.1:9393/messages/1/rank/dec -d ''
  put "/messages/:id/rank/dec" do |id|
    msg = MessageUpdateModel.new(:ids=>[id.to_i])
    msg.message.rank -= 1
    result = msg.update
    
    render_output 'updated_message', result
  end

end
