# encoding: utf-8
# author: rpolasek

# TODO: custom exception
# TODO: hash (geo location) validation

module MessageModel

  # TODO: it would be more exact (february and leap-year)
  DATE_TIME_REGEXP = /
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

  DATE_TIME_FORMAT = '<yyyy-mm-dd>T<hh:mm:ss>'

  # TODO: initialization needed?
  def self.included(base)
  end

  # --- for elasticsearch

  def type
    'askme'
  end

  def to_indexed_json
    @args.to_json
  end

  protected

  # --- data validation

  def validate_before_save
    errors = []
    # validate required fields
    @model[:required].each do |field|
      errors << error_msg(field, true) if @args[field].nil? || !valid?(field)
    end
    # validate the rest
    (@model[:fields].keys - @model[:required]).each do |field|
      errors << error_msg(field) unless valid?(field)
    end
    return errors
  end

  def validate_before_find
    errors = []
    # validate all fields (they may be nil or '')
    @model[:fields].keys.each do |field|
      unless args[field].nil?
        errors << error_msg(field) unless valid?(field)
      end
    end
    return errors
  end

  private

  def field_type(field)
    field_spec = @model[:fields][field]
    field_spec.is_a?(Array) ? eval(field_spec[0].to_s) : eval(field_spec.to_s)
  end

  # TODO: field must be an Array
  def field_value_type(field)
    field_spec = @model[:fields][field]
    case field_spec[0]
    when :Array then eval(field_spec[1].to_s) # String
    when :String then field_spec[1]           # Regexp
    else raise 'unknown value type to validate'
    end
  end

  # TODO: field must be an Array
  def field_value_format(field)
    field_spec = @model[:fields][field]
    if field_spec.size > 2
      "format #{field_spec[2]}" # Regexp (format)
    else
      eval(field_spec[1].to_s)  # String
    end
  end

  def valid?(field)
    field_spec = @model[:fields][field]
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
		
    elsif field_spec.is_a?(Hash)
      return true # TODO: ignore hash validation

    else
      @args[field].is_a?(field_type(field))
    end
  end

  def error_msg(field, required=false)
    msg = "field '#{field}' "
    msg.concat('is required and ') if required
    msg.concat("must be #{field_type(field)}")
    if @model[:fields][field].is_a?(Array)
      msg += " of #{field_value_format(field)}"
    end
    msg += " => '#{@args[field]}'"
    return msg
  end

end

# vim:ff=unix ts=2 ss=2 sts=2 et
