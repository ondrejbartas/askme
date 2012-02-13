# -*- encoding : utf-8 -*-
require 'sinatra'
require 'sinatra/base'
require 'erb'

#including Sinatra methods
Dir[File.join(File.dirname(__FILE__),"/app_sinatra/*.rb")].each {|file| require file }

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end  

class AskmeSinatra < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/app_sinatra/views'
end
