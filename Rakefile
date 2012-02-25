# -*- encoding : utf-8 -*-
ENV['RACK_ENV'] ||= "development"

require './askme_app'
require './askme_sinatra'
require 'rack/test'
require 'rake/testtask'
require 'rcov/rcovtask'

Dir["tasks/*.rake"].sort.each { |ext| load ext }

#get directories!
PIDS_DIR = File.expand_path(File.join("..", "tmp","pid"), __FILE__)
CONF_DIR = File.expand_path(File.join("..", "config"), __FILE__)
#create directory for pid files
FileUtils.mkdir_p(PIDS_DIR) unless File.exists?(PIDS_DIR)
REDIS_PID = File.join(PIDS_DIR, "redis.pid")

#copy example config files for redis and elastic if they don't exists
FileUtils.cp(File.join(CONF_DIR, "redis_config.yml.example"), File.join(CONF_DIR, "redis_config.yml") ) unless File.exists?(File.join(CONF_DIR, "redis_config.yml")) 
FileUtils.cp(File.join(CONF_DIR, "elastic_config.yml.example"), File.join(CONF_DIR, "elastic_config.yml") ) unless File.exists?(File.join(CONF_DIR, "elastic_config.yml")) 

#for testing purposes use 
REDIS_CNF = File.join(File.expand_path(File.join("..","config"), __FILE__), "redis_test.conf")


task :default => :run

desc "Run tests and manage databases start/stop"
task :run => [:'redis:start', :'test', :'redis:stop']

desc "Start databases"
task :startup => [:'redis:start']

desc "Teardown databases"
task :teardown => [:'redis:stop']

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/functional/*_test.rb', 'test/unit/*_test.rb','test/integration/*_test.rb']
  t.warning = false
  t.verbose = false
end

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.test_files = FileList['test/unit/**/*.rb']
    t.warning = false
    t.verbose = false
  end

  Rake::TestTask.new(:functional) do |t|
    t.test_files = FileList['test/functional/**/*.rb']
    t.warning = false
    t.verbose = false
  end

  Rake::TestTask.new(:integration) do |t|
    t.test_files = FileList['test/integration/**/*.rb']
    t.warning = false
    t.verbose = false
  end
end

namespace :redis do
  desc "Start the Redis server"
  task :start do
    redis_running = \
    begin
      File.exists?(REDIS_PID) && Process.kill(0, File.read(REDIS_PID).to_i)
    rescue Errno::ESRCH
      FileUtils.rm REDIS_PID
      false
    end
    system "pwd"
    puts system "redis-server #{REDIS_CNF}" unless redis_running
    puts "redis started"
  end

  desc "Stop the Redis server"
  task :stop do
    if File.exists?(REDIS_PID)
      Process.kill "INT", File.read(REDIS_PID).to_i
      FileUtils.rm REDIS_PID
      puts "redis stopped"
    end
  end
end