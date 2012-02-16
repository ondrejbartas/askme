# -*- encoding : utf-8 -*-
class AskmeSinatra < Sinatra::Base
  
  def render_output name = nil, items = nil
    content_type :json
    output = {:status => "ok", :message => "ok", :executed_at => Time.now.strftime("%Y-%m-%d %H:%M:%S") }
    output[name] = items unless name
    return JSON.pretty_generate(output)
  end
  
  #Get all messages
  get_or_post "/messages" do
    #Code for getting messages goes there, it should be automatically search too
    items = []
    render_output "messages", items
  end
  
  #Create message
  get_or_post "/message/create" do
    #Code for creating messsage goes there
    render_output
  end
  
  #Get all tags
  get_or_post "/tags" do
    #Code for getting tags goes there, it should be automatically search too
    items = []
    render_output "tags", items
  end
  
  #Create tag
  get_or_post "/tag/create" do
    #Code for creating tag goes there
    render_output
  end
  
end
