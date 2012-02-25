# -*- encoding : utf-8 -*-
class AskmeSinatra < Sinatra::Base
  
  def get_id_from_url id
    return id.scan(/\d+/).first.to_i if id && id.size > 0  
    return nil
  end
  
  def render_output name = nil, items = nil
    content_type :json
    output = {:status => "ok", :message => "ok", :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S") }
    output[name] = items unless name
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
  
  #Get all messages
  get %r{/messages(\z|/[\d]*)} do |id|
    id = get_id_from_url id
    #Code for getting messages goes there, it should be automatically search too
    items = []
    items << id
    render_output "messages", items
  end
  
  #Create message
  post "/messages" do
    message_id = RedisID.get(:message)
    #Code for creating messsage goes there
    render_output
  end
  
  #Get all tags
  get %r{/tags(\z|/[\d]*)} do |id|
    id = get_id_from_url id
    #Code for getting tags goes there, it should be automatically search too
    items = []
    render_output "tags", items
  end
  
  #Create tag
  post "/tag/create" do
    tag_id = RedisID.get(:tag)
    #Code for creating tag goes there
    render_output
  end
  
end
