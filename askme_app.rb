# -*- encoding : utf-8 -*-
require 'rubygems'
require 'rack'
require 'pp'
require 'json'
require 'unicode'
require 'uri'
require 'redis'

require 'active_support'
require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/class/inheritable_attributes'

require 'date'
require 'logger'

require 'mail'

require 'redis-model-extension'

require 'tire'

ENV['RACK_ENV'] ||= "development"

autoload :MessageModel, File.join(File.dirname(__FILE__),'/lib/message_model.rb')

#including lib
Dir[File.join(File.dirname(__FILE__),"/lib/*.rb")].each {|file| require file }

#including main classes
Dir[File.join(File.dirname(__FILE__),"/app/*.rb")].each {|file| require file }

require './config/initializer'
require './config/assets'
