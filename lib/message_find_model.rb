# encoding: utf-8
# author: rpolasek
# vim:ff=unix ts=2 ss=2 sts=2 et

# TODO: custom exception

class MessageFindModel

  include MessageModel

  attr_reader :model

  attr_reader :args
  attr_reader :ids, :thread_ids, :authors, :message, :start_date_time, :end_date_time, :tags, :recipients, :rank, :location # automatically instantinated
  
  # computed
  attr_reader :start_date, :start_time, :end_date, :end_time
  attr_reader :rank_value, :rank_tolerance
  attr_reader :location_lat, :location_lon, :location_radius

  #
  # <field> : <field_type>
  # <field> : [ <field_type>, <field_value_type>, <field_value_format>
  #
  MODEL = {
    :fields => {
      :ids              => [:Array, :Fixnum],
      :thread_ids       => [:Array, :Fixnum],
      :authors          => [:Array, :String],
      :message          => :String,
      :start_date_time  => [:String, MessageModel::DATE_TIME_REGEXP, MessageModel::DATE_TIME_FORMAT],
      :end_date_time    => [:String, MessageModel::DATE_TIME_REGEXP, MessageModel::DATE_TIME_FORMAT],
      :tags             => [:Array, :String],
      :recipients       => [:Array, :String],
      :rank             => [:Array, :Fixnum], # [rank, tolerance] -> <rank-tolerance; rank+tolerance>
      :location         => { :lat => :Fixnum, :lon => :Fixnum, :radius => :Fixnum }
      #:location         => [:Array, :Fxinum]  # [lat, lon, radius] -> [lat, lon] +- radius
    }
  }

  def initialize(args={})
    @model = MODEL

    @args = args
    @args.each_pair { |name, value| instance_variable_set(:"@#{name}", value) }

    @start_date, @start_time = @start_date_time.split('T') unless @start_date_time.nil?
    @end_date, @end_time = @end_date_time.split('T') unless @end_date_time.nil?

    @rank_value, @rank_tolerance = @rank unless @rank.nil?
    @location_lat, @location_lon, @location_radius = @location.values unless @location.nil?
    #@location_lat, @location_lon, @location_radius = @location unless @location.nil?
  end

  # --- for elasticsearch adapter

  def find
    err_msg = validate_before_find
    raise err_msg.join("\n") unless err_msg.empty?
		
    ElasticSearchAdapter.find(self)
  end

end
