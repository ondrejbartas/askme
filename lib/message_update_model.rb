# encoding: utf-8
# author: rpolasek

# TODO: custom exception

class MessageUpdateModel

  include MessageModel

  attr_reader :message

  def initialize(args)
    result = MessageFindModel.new(args).find
    raise 'not found' if result.empty?

    @message = MessageCreateModel.new(result_to_message(result))
  end

  def update
    @message.id = @message.id.to_i # FIXME: why it is needed? :-(
    @message.save
  end
  
  protected

  # TODO: must be just one match
  def result_to_message(result)
    message = result[0].to_hash.clone
    result[0].to_hash.keys.each { |field| message.delete(field) unless MessageCreateModel::MODEL[:fields].include?(field) }
    
    return message
  end
  
end

# vim:ff=unix ts=2 ss=2 sts=2 et
