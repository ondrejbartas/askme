# encoding: utf-8
# author: rpolasek
class ElasticSearchAdapter
	
	def self.save(message)
		if message.is_a?(MessageModel)
			Tire.index('askme') do
				store(message)
				refresh
			end
		end
	end

	def self.find(message)
		# TODO: oops! it will be really a challenge...
		raise 'not implemented yet'
	end

	def self.find_by_id(id)
		Tire.search('askme') { query { string "id:#{id}" } }.results
	end

	def self.find_by_author(id)
		Tire.search('askme') { query { string "author_id:#{id}" } }.results
  end

  def self.find_by_thread(id)
		Tire.search('askme') { query { string "thread_id:#{id}" } }.results
  end

	# TODO: it would be fine to accept a regexp
  def self.find_message(str)
		Tire.search('askme') { query { string "message:#{str}" } }.results
  end

	# TODO: date format <yyyy-mm-dd>
  def self.find_by_date(date)
		Tire.search('askme') { query { boolean { must { string "date_time:[#{date}T00:00:00 TO #{date}T23:59:59]" } } } }.results
  end

	# TODO: date format <yyyy-mm-dd>
  def self.find_by_date_interval(start_date, end_date)
		Tire.search('askme') { query { boolean { must { string "date_time:[#{start_date}T00:00:00 TO #{end_date}T23:59:59]" } } } }.results
  end

	# TODO: date format <yyyy-mm-dd>, time format <hh:mm:ss>
  def self.find_by_date_time(date, start_time, end_time)
		Tire.search('askme') { query { boolean { must { string "date_time:[#{date}T#{start_time} TO #{date}T#{end_time}]" } } } }.results
  end

	# TODO: date format <yyyy-mm-dd>, time format <hh:mm:ss>
  def self.find_by_date_time_interval(start_date, end_date, start_time, end_time)
		Tire.search('askme') { query { boolean { must { string "date_time:[#{start_date}T#{start_time} TO #{end_date}T#{end_time}]" } } } }.results
  end

	# TODO: tags must be an array
  def self.find_by_tags(tags, minimum_match=1)
		Tire.search('askme') { query { terms :tags, tags, :minimum_match => minimum_match } }.results
  end

	# TODO: recipients must be an array
  def self.find_by_recipients(recipients)
		Tire.search('askme') { query { boolean { recipients.each { |recip| should { string "recipients:#{recip}" } } } } }.results
  end

end
