# encoding: utf-8
# author: rpolasek
# vim:ff=unix ts=2 ss=2 sts=2 et

# TODO: custom exception

class MessageModel

  attr_accessor :args
  attr_accessor :id, :author_id, :message, :thread_id, :tags, :recipients # automatically instantinated
  attr_accessor :date, :time, :date_time # computed


  # TODO: it would be more exact (february and leap-year)
  date_time_regexp = /
    (?<date>
      2\d{3}            # year
      -
      (
        0\d | 1[0-2]    # month
      )
      -
      (
        [0-2]\d | 3[01] # day
      )
    ){0}

    (?<time>
      (
        [01]\d | 2[0-3] # hours
      )
      :
      [0-5]\d           # minutes
      :
      [0-5]\d           # seconds
    ){0}

    ^\g<date>T\g<time>$
  /x

  #
  # <field> : <field_type>
  # <field> : [ <field_type>, <field_value_type>, <field_value_format>
  #
  MESSAGE_MODEL = {
    :fields => {
      :id         => :Integer,
      :author_id  => :Integer,
      :thread_id  => :Integer,
      :message    => :String,
      :date_time  => [:String, date_time_regexp, '<yyyy-mm-dd>T<hh:mm:ss>'],
      :tags       => [:Array, :String],
      :recipients => [:Array, :String]
    },
    :required => [ :id, :author_id, :message, :thread_id ]
  }

  def initialize(args={})
    @args = args
    @args.each_pair { |name, value| instance_variable_set(:"@#{name}", value) }

    @date, @time = Time.now.getutc.to_s.split(" ")
    @date_time = "#{@date}T#{@time}"
    @tags, @recipients = parse_message(@message)
		
    @args[:date_time] ||= @date_time
    @args[:tags] ||= @tags
    @args[:recipients] ||= @recipients
  end

  # --- for elasticsearch adapter

  def type
    'askme'
  end

  def to_indexed_json
    @args.to_json
  end

  def save
    err_msg = validate_before_save
    raise err_msg.join(";") unless err_msg.empty?
		
    ElasticSearchAdapter.save(self)
  end

  def find
    err_msg = validate_before_find
    raise err_msg.join(";") unless err_msg.empty?
		
    ElasticSearchAdapter.find(self)
  end

  protected

  def parse_message(message)
    tags = message.scan(/\s+#([^\s.,;:]+)/).flatten
    recipients = message.scan(/\s+@([^\s.,;:]+)/).flatten
    return tags, recipients
  end

  private

  # --- data validation

  def field_type(field)
    field_spec = MESSAGE_MODEL[:fields][field]
    field_spec.is_a?(Array) ? eval(field_spec[0].to_s) : eval(field_spec.to_s)
  end

  # TODO: field must be an Array
  def field_value_type(field)
    field_spec = MESSAGE_MODEL[:fields][field]
    case field_spec[0]
    when :Array then eval(field_spec[1].to_s) # String
    when :String then field_spec[1]           # Regexp
    else raise 'unknown value type to validate'
    end
  end

  # TODO: field must be an Array
  def field_value_format(field)
    field_spec = MESSAGE_MODEL[:fields][field]
    if field_spec.size > 2
      "format #{field_spec[2]}" # Regexp (format)
    else
      eval(field_spec[1].to_s)  # String
    end
  end

  def valid?(field)
    field_spec = MESSAGE_MODEL[:fields][field]
    if field_spec.is_a?(Array)
      return false unless @args[field].is_a?(field_type(field))
			
      case field_spec[0]
      when :Array
        @args[field].each { |value| return false unless value.is_a?(field_value_type(field)) }
        return true
      when :String
        if field_spec[1].is_a?(Regexp)
          return @args[field] =~ field_spec[1] ? true : false # match a format
        else
          return true # check is not required
        end
      else
        raise 'unknown field type to validate'
      end
		
    else
      @args[field].is_a?(field_type(field))
    end
  end

  def error_msg(field)
    msg = "field '#{field}' is required and must be #{field_type(field)}"
    if MESSAGE_MODEL[:fields][field].is_a?(Array)
      msg += " of #{field_value_format(field)}"
    end
    msg += " => '#{@args[field]}'"
    return msg
  end

  def validate_before_save
    errors = []
    # validate required fields
    MESSAGE_MODEL[:required].each do |field|
      errors << error_msg(field) if @args[field].nil? || !valid?(field)
    end
    # validate the rest
    (MESSAGE_MODEL[:fields].keys - MESSAGE_MODEL[:required]).each do |field|
      errors << error_msg(field) unless valid?(field)
    end
    return errors
  end

  def validate_before_find
    errors = []
    # validate all fields (they may be nil)
    MESSAGE_MODEL[:fields].each do |field|
      unless field.nil?
        errors << error_msg(field) unless valid?(field)
      end
    end
    return err_msg
  end

end
