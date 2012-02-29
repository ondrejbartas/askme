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
  
  # for the elasticsearch

  # get a message for the appropriate message id
  get "/message/:id" do |id|
    # TODO: exception
    msg = MessageFindModel.new :ids => [id.to_i]
    result = msg.find

    render_output 'found_message', result[0]
  end

  # get message(s) (complex search query)
  get '/message' do
    # TODO: exception
    msg = MessageFindModel.new(params)
    result = msg.find

    render_output "found_message(s)", result
  end

  # create a message
  post '/message' do
    message = params
    message['id'] = RedisID.get(:message)

    # TODO: exception
    msg = MessageCreateModel.new(message)
    result = msg.save

    render_output "saved_message", result
  end
  
  # ++rank
  post "/rank/inc/:id" do |id|
    # TODO: call to increase a rank for message id
  end

  # --rank
  post "/rank/dec/:id" do |id|
    # TODO: call to descrease a rank for message id
  end

end
