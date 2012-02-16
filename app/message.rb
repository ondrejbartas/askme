# -*- encoding : utf-8 -*-
class Message
  
  attr_accessor :user, :recepients, :message_id, :thread_id, :created_at, :message, :location, :tag
  
# Example object in Elastic Search
# {
#    "message" : {
#       "user": 123,
#       "recepients": [234,567],            #optional, if sb want to send message to
#       "message_id": "hashForMessage",
#       "thread_id":  "hashOfMessageParent",
#       "created_at": Time,
#       "location": {                       #http://www.elasticsearch.org/blog/2010/08/16/geo_location_and_search.html
#           "lat": 40,
#           "lon": 70   
#       },
#       "tag": ["food", "restaurants"],     #for discusion -> use ids or names?
#       "message": "Good news, there is a nice new #restaurant out there on 
#                   the corner where you can get tasty #food. @alex @philip"  
#    }
#  }
  
end