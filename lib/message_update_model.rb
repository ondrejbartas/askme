
# encoding: utf-8
# author: rpolasek
# vim:ff=unix ts=2 ss=2 sts=2 et

# TODO: custom exception

class MessageUpdateModel

  include MessageModel

  attr_reader :message

  def initialize(message)
    msg = MessageFindModel.new(message)
    result = msg.find
    raise 'not found' if result.size == 0

    new_message = result[0].to_hash.clone
    result[0].to_hash.keys.each { |field| new_message.delete(field) unless MessageCreateModel::MODEL[:fields].include?(field) }

    @message = MessageCreateModel.new(new_message)
    @message.id = @message.id.to_i # FIXME: why it is needed? :-(
  end

  def update
    @message.save
  end
  
end
