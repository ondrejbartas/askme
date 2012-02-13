# config.ru
require './askme_app.rb'
require './askme_sinatra.rb'

# Map applications
run Rack::URLMap.new \
  "/"       => AskmeSinatra.new
