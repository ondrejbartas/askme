# -*- encoding : utf-8 -*-
ENV['RACK_ENV'] ||= "development"

require './askme_app'
require './askme_sinatra'
require 'rack/test'
require 'rake/testtask'
require 'rcov/rcovtask'

Dir["tasks/*.rake"].sort.each { |ext| load ext }
