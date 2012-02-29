# encoding: utf-8
# author: rpolasek
# vim:ff=unix ts=2 ss=2 sts=2 et

# TODO: custom exception
# TODO: find by geo location
#       - http://www.elasticsearch.org/blog/2010/08/16/geo_location_and_search.html
#       - https://github.com/elasticsearch/elasticsearch/issues/279

class ElasticSearchAdapter
	
  def self.save(message)
    raise 'unknown message to save' unless message.is_a?(MessageCreateModel)
    
    Tire.index('askme') do
      store(message)
      refresh
    end
  end

  def self.find(message)
    raise 'unknown message to find' unless message.is_a?(MessageFindModel)
    raise 'empty query' if message.args.keys.size == 0
    
    if message.args.keys.size == 1
      make_simple_query(message)
    else
      make_complex_query(message)
    end
  end

  # methods for testing (they will be private)

  def self.find_by_id(id)
    if id.is_a?(Array)
      Tire.search('askme') { query { boolean { id.each { |message_id| should { string "id:#{message_id}" } } } } }.results
    else
      Tire.search('askme') { query { string "id:#{id}" } }.results
    end
  end

  def self.find_by_thread(id)
    if id.is_a?(Array)
      Tire.search('askme') { query { boolean { id.each { |thread_id| should { string "thread_id:#{thread_id}" } } } } }.results
    else
      Tire.search('askme') { query { string "thread_id:#{id}" } }.results
    end
  end

  def self.find_by_author(name)
    if name.is_a?(Array)
      Tire.search('askme') { query { boolean { name.each { |author| should { string "author:#{author}" } } } } }.results
    else
      Tire.search('askme') { query { string "author:#{name}" } }.results
    end
  end

  # TODO: it would be fine to accept a regexp
  def self.find_message(str)
    Tire.search('askme') { query { string "message:#{str}" } }.results
  end

  # date format <yyyy-mm-dd>
  def self.find_by_date(date)
    raise "param 'date' has a wrong date format: '#{date}'" unless date_contains?(date)

    Tire.search('askme') { query { boolean { must { string "date_time:[#{date}T00:00:00 TO #{date}T23:59:59]" } } } }.results
  end

  # date format <yyyy-mm-dd>
  def self.find_by_date_interval(start_date, end_date)
    raise "param 'start_date' has a wrong date format: '#{start_date}'" unless date_contains?(start_date)
    raise "param 'end_date' has a wrong date format: '#{end_date}'" unless date_contains?(end_date)

    Tire.search('askme') { query { boolean { must { string "date_time:[#{start_date}T00:00:00 TO #{end_date}T23:59:59]" } } } }.results
  end

  # date format <yyyy-mm-dd>, time format <hh:mm:ss>
  def self.find_by_date_time(date, start_time, end_time)
    raise "param 'date' has a wrong date format: '#{date}'" unless date_contains?(date)
    raise "param 'start_time' has a wrong time format: '#{start_time}'" unless time_contains?(start_time)
    raise "param 'end_time' has a wrong time format: '#{end_time}'" unless time_contains?(end_time)

    Tire.search('askme') { query { boolean { must { string "date_time:[#{date}T#{start_time} TO #{date}T#{end_time}]" } } } }.results
  end

  # date format <yyyy-mm-dd>, time format <hh:mm:ss>
  def self.find_by_date_time_interval(start_date, start_time, end_date, end_time)
    raise "param 'start_date' has a wrong date format: '#{start_date}'" unless date_contains?(start_date)
    raise "param 'start_time' has a wrong time format: '#{start_time}'" unless time_contains?(start_time)
    raise "param 'end_date' has a wrong date format: '#{end_date}'" unless date_contains?(end_date)
    raise "param 'end_date' has a wrong time format: '#{end_time}'" unless time_contains?(end_time)

    Tire.search('askme') { query { boolean { must { string "date_time:[#{start_date}T#{start_time} TO #{end_date}T#{end_time}]" } } } }.results
  end

  # tags must be an array
  def self.find_by_tags(tags, minimum_match=1)
    raise "param 'tags' must be an array" unless tags.is_a?(Array)

    Tire.search('askme') { query { terms :tags, tags, :minimum_match => minimum_match } }.results
  end

  # recipients must be an array
  def self.find_by_recipients(recipients)
    raise "param 'recipients' must be an array" unless recipients.is_a?(Array)

    Tire.search('askme') { query { boolean { recipients.each { |recip| should { string "recipients:#{recip}" } } } } }.results
  end

  def self.find_by_rank(rank, tolerance=0)
    Tire.search('askme') { query { range :rank, :from => rank-tolerance, :to => rank+tolerance } }.results
  end

  protected

  def self.make_simple_query(message)
    args = message.args

    case args.keys[0]
    when :ids
      find_by_id(message.ids)
    when :thread_ids
      find_by_thread(message.thread_ids)
    when :authors
      find_by_author(message.authors)
    when :message
      find_message(message.message)
    when :start_date_time # lowest date -> <:start_date_time, today>
      end_date, end_time = Time.now.strftime('%Y-%m-%dT%H:%M:%S').split('T')
      find_by_date_time_interval(message.start_date, message.start_time, end_date, end_time)
    when :tags
      find_by_tags(message.tags)
    when :recipients
      find_by_recipients(message.recipients)
    when :rank
      tolerance = message.rank_tolerance.nil? ? 0 : message.rank_tolerance
      find_by_rank(message.rank_value, tolerance)
    when :location
      # TODO: geo location
      raise 'not implemented'
    end
  end

  # note: search by id is nonsense just here i think
  #
  #     [thread_id1 and thread_id2, ...]
  # and [author1 and author2, ...]
  # and message
  # and between <start_date_time; end_date_time>
  # and [tag1 and tag2, ...]
  # and [recipient1 or recipient2, ...]
  # and [rank, tolerance]
  # and [location, radius]
  def self.make_complex_query(message)
    args = message.args

    Tire.search('askme') do
      query do
        boolean do
          must do
          
            # authors
            boolean { message.authors.each { |author| should { string "authors:#{author}" } } } if args.include?(:authors)

            # thread_ids
            boolean { message.thread_ids.each { |thread_id| should { string "thread_ids:#{thread_id}" } } } if args.include?(:thread_ids)

            # message
            string "message:#{message.message}" if args.include?(:message)

            # <start_date_time; end_date_time>
            if args.include?(:start_date_time) && args.include?(:end_date_time)
              string "date_time:[#{message.start_date_time} TO #{message.end_date_time}]" 
            elsif args.include?(:start_date_time)
              string "date_time:[#{message.start_date_time} TO #{Time.now.strftime('%Y-%m-%dT%H:%M:%S')}]"
            elsif args.include?(:end_date_time)
              string "date_time:[#{Time.at(0).strftime('%Y-%m-%dT%H:%M:%S')} TO #{message.end_date_time}]"
            end

            # tags
            terms :tags, message.tags if args.include?(:tags)

            # recipients
            boolean { message.recipients.each { |recip| should { string "recipients:#{recip}" } } } if args.include?(:recipients)

            # rank
            if args.include?(:rank)
              tolerance = message.rank_tolerance.nil? ? 0 : message.rank_tolerance
              range :rank, :from => message.rank_value-tolerance, :to => message.rank_value+tolerance
            end

            # TODO: geo location
            raise 'not implemented' if args.include?(:location)

          end
        end
      end
    end.results
  end

  private

  def self.date_contains?(date_time)
    date_time.match(/2\d{3}-(0\d|1[0-2])-([0-2]\d|3[01])/) != nil
  end

  def self.time_contains?(date_time)
    date_time.match(/([01]\d|2[0-3]):[0-5]\d:[0-5]\d/) != nil
  end
end