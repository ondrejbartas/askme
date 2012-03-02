# encoding: utf-8
# author: rpolasek

# TODO: custom exception
# TODO: geo location

class MessageCreateModel

  include MessageModel

  attr_reader :model
  attr_reader :args
  
  attr_accessor :id, :thread_id, :author, :message, :rank, :location # automatically instantinated
  
  # computed
  attr_reader :tags, :recipients
  attr_reader :date, :time, :date_time
  attr_reader :location_lat, :location_lon

  #
  # <field> : <field_type>
  # <field> : [ <field_type>, <field_value_type>, <field_value_format>
  #
  MODEL = {
    :fields => {
      :id         => :Fixnum,
      :thread_id  => :Fixnum,
      :author     => :String,
      :message    => :String,
      :date_time  => [:String, MessageModel::DATE_TIME_REGEXP, MessageModel::DATE_TIME_FORMAT],
      :tags       => [:Array, :String],
      :recipients => [:Array, :String],
      :rank       => :Fixnum, # default = 0
      :location   => { :lat => :Fixnum, :lon => :Fixnum }
      #:location   => [:Array, :Fixnum] # [lat, lon]
    },
    :required => [ :id, :thread_id, :author, :message ]
  }

  def initialize(args={})
    @model = MODEL

    @args = args
    @args.each_pair { |name, value| instance_variable_set(:"@#{name}", value) }

    @date, @time = Time.now.getutc.to_s.split(" ")
    @date_time = "#{@date}T#{@time}"
    @args[:date_time] ||= @date_time

    parse_message

    @rank = 0 if @rank.nil?
    @args[:rank] ||= @rank

    @location_lat, @location_lon = @location.values unless @location.nil?
    #@location_lat, @location_lon = @location unless @location.nil?
  end

  # --- for elasticsearch adapter

  def save
    synchronize_fields
    err_msg = validate_before_save
    raise err_msg.join("\n") unless err_msg.empty?
		
    ElasticSearchAdapter.save(self)
  end

  protected

  def parse_message
    @tags = @message.scan(/\s+#([^\s.,;:]+)/).flatten
    @args[:tags] ||= @tags
    
    @recipients = @message.scan(/\s+@([^\s.,;:]+)/).flatten
    @args[:recipients] ||= @recipients
  end

  # for update: args[attr] <- attr
  def synchronize_fields
    parse_message
    MODEL[:fields].keys.each { |field| @args[field] = method(field).call if @args.include?(field) }
  end

end

# vim:ff=unix ts=2 ss=2 sts=2 et
