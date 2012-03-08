# -*- encoding : utf-8 -*-
class AskmeSinatra < Sinatra::Base
  
  def render_output name = nil, items = nil
    content_type :json
    output = {:status => "ok", :status_message => "ok", :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S") }
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
    message_id = RedisId.get(:user)
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
    login_required
    result = MessageFindModel.new(:ids=>[id.to_i]).find
    render_output 'messages', result[0]
  end

  # get message(s) (complex search query)
  get '/messages' do
    login_required
    args = params.symbolize_keys
    args[:authors] = args[:message].scan(/@([^\s.,;:]+)/).flatten
    args[:message].gsub!(/@([^\s.,;:]+)/,"")
    result = MessageFindModel.new(args).find
    return JSON.pretty_generate(result.results)
  end

  # create a message
  post '/messages' do
    login_required
    if params.size == 0
      #if params are in post body -> strip them
      message = JSON.parse(request.body.read.to_s) 
    else 
      #params are in header or url
      message = params.clone
    end
    message["author"] = @current_user.get_name
    message["id"] = RedisId.get(:message)
    message["thread_id"] = message["id"] if message["thread_id"].nil?
    result = MessageCreateModel.new(message.symbolize_keys).save
    render_output 'saved_message', result
  end
  
  # ++rank : curl -XPUT http://127.0.0.1:9393/messages/1/rank/inc -d ''
  put "/messages/:id/rank/inc" do |id|
    login_required
    msg = MessageUpdateModel.new(:ids=>[id.to_i])
    msg.message.rank += 1
    result = msg.update
    
    render_output 'updated_message', result
  end

  # --rank : curl -XPUT http://127.0.0.1:9393/messages/1/rank/dec -d ''
  put "/messages/:id/rank/dec" do |id|
    login_required
    msg = MessageUpdateModel.new(:ids=>[id.to_i])
    msg.message.rank -= 1
    result = msg.update
    
    render_output 'updated_message', result
  end

end
