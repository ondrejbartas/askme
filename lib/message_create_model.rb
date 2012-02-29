# encoding: utf-8
# author: rpolasek
# vim:ff=unix ts=2 ss=2 sts=2 et

# TODO: custom exception

class MessageCreateModel

  include MessageModel

  attr_reader :model

  attr_accessor :args
  attr_accessor :id, :thread_id, :author, :message, :tags, :recipients, :rank, :location # automatically instantinated
  
  # computed
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

    @tags, @recipients = parse_message(@message)
    @args[:tags] ||= @tags
    @args[:recipients] ||= @recipients

    @rank = 0 unless @rank.nil?
    @args[:rank] ||= @rank

    @location_lat, @location_lon = @location.values unless @location.nil?
    #@location_lat, @location_lon = @location unless @location.nil?
  end

  # --- for elasticsearch adapter

  def save
    err_msg = validate_before_save
    raise err_msg.join("\n") unless err_msg.empty?
		
    ElasticSearchAdapter.save(self)
  end

  protected

  def parse_message(message)
    tags = message.scan(/\s+#([^\s.,;:]+)/).flatten
    recipients = message.scan(/\s+@([^\s.,;:]+)/).flatten
    return tags, recipients
  end

end
