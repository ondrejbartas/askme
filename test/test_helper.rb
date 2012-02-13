ENV['RACK_ENV'] = "test"

require 'rack/test'
require 'test/unit'
require './askme_app'
require './askme_sinatra'
require 'turn'
require 'shoulda-context'

require 'bundler'
Bundler.setup