# encoding: utf-8
# author: rpolasek

# TODO: custom exception
# TODO: find by geo location
#       - http://www.elasticsearch.org/blog/2010/08/16/geo_location_and_search.html
#       - https://github.com/elasticsearch/elasticsearch/issues/279

class ElasticSearchAdapter
	
  @@index = 'askme'

  def self.save(message)
    raise 'unknown message to save' unless message.is_a?(MessageCreateModel)
    
    Tire.index(@@index) do
      store(message)
      refresh
    end
  end

  def self.find(message)
    raise 'unknown message to find' unless message.is_a?(MessageFindModel)
    
    execute_query(message).results
  end

  def self.index
    @@index
  end

  def self.index=(index)
    @@index = index
  end

  protected

  #     [thread_id1 or thread_id2, ...]
  # and [author1 or author2, ...]
  # and message
  # and between <start_date_time; end_date_time>
  # and [tag1 and tag2, ...]
  # and [recipient1 and recipient2, ...]
  # and [rank, tolerance]
  # and [location, radius]
  def self.execute_query(message)
    args = message.args

    Tire.search(@@index) do
      query do
        boolean do
          
          # id
          message.ids.each { |id| should { string "id:#{id}" } } if args.include?(:ids)

          # thread_id
          message.thread_ids.each { |thread_id| should { string "thread_id:#{thread_id}" } } if args.include?(:thread_ids) 

          # author
          message.authors.each { |author| must { string "author:#{author}" } } if args.include?(:authors)

          # message
          must { string "message:*#{message.message}*" } if args.include?(:message)

          # <start_date_time; end_date_time>
          if args.include?(:start_date_time) && args.include?(:end_date_time)
            must { string "date_time:[#{message.start_date_time} TO #{message.end_date_time}]" }
          elsif args.include?(:start_date_time)
            must { string "date_time:[#{message.start_date_time} TO #{Time.now.strftime('%Y-%m-%dT%H:%M:%S')}]" } 
          elsif args.include?(:end_date_time)
            must { string "date_time:[#{Time.at(0).strftime('%Y-%m-%dT%H:%M:%S')} TO #{message.end_date_time}]" } 
          end
          
          # tags
          must { terms :tags, message.tags, :minimum_match=>message.tags.size } if args.include?(:tags)

          # recipients
          message.recipients.each { |recipient| must { string "recipients:#{recipient}" } } if args.include?(:recipients)

          # rank
          if args.include?(:rank)
            tolerance = message.rank_tolerance.nil? ? 0 : message.rank_tolerance
            must { range :rank, :from=>message.rank_value-tolerance, :to=>message.rank_value+tolerance } 
          end

          # TODO: geo location
          raise 'not implemented' if args.include?(:location)

        end
      end
    end
   
  end

end
