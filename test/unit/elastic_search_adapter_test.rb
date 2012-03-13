# encoding: utf-8
# author: rpolasek

require './test/test_helper'

class ElasticSearchAdapterTest < Test::Unit::TestCase
  
  context 'elasticsearch adapter' do

    setup do
      ElasticSearchAdapter.index = 'askme_test'

      Tire.index(ElasticSearchAdapter.index) do
        delete
        create
      end
    end
 
    teardown do
      Tire.index(ElasticSearchAdapter.index) { delete }
    end

    should('found no records') do
      assert_equal(MessageFindModel.new(:ids => [12345]).find.empty?, true)
    end
    
    should('create just one message') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #message about #askme for @ondra').save

      result = MessageFindModel.new(:ids=>[1]).find

      assert_equal(result.empty?, false)
      assert_equal(result.size, 1)
      
      assert_equal(result[0][:id].to_i, 1)
      assert_equal(result[0][:author], 'radim')
      assert_equal(result[0][:thread_id], 1)
      assert_equal(result[0][:message], 'this is the 1st #message about #askme for @ondra')
      assert_equal(result[0][:tags], ['message', 'askme'])
      assert_equal(result[0][:recipients], ['ondra'])
      assert_equal(result[0][:rank], 0)
    end

    should('create next message and update it') do
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #message about #askme for @radim').save

      msg = MessageUpdateModel.new(:ids=>[2])
      msg.message.message = 'this is the 2nd #updated about #askme for @radim @all'
      msg.message.rank += 1
      msg.update

      result = MessageFindModel.new(:ids=>[2]).find

      assert_equal(result.empty?, false)
      assert_equal(result.size, 1)
      
      assert_equal(result[0][:id].to_i, 2)
      assert_equal(result[0][:author], 'ondra')
      assert_equal(result[0][:thread_id], 1)
      assert_equal(result[0][:message], 'this is the 2nd #updated about #askme for @radim @all')
      assert_equal(result[0][:tags], ['updated', 'askme'])
      assert_equal(result[0][:recipients], ['radim', 'all'])
      assert_equal(result[0][:rank], 1)
    end

    should('find one record by a string contained in the message') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra').save
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim').save
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about #askme for @radim').save
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th popokatepetl #tag4 about #askme for @ondra').save  # match
      
      result = MessageFindModel.new(:message=>"popokatepetl").find

      assert_equal(result.size, 1)
    end

    should('find two records by a part of a string contained in the message') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra').save
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim').save
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd popokate #tag3 about #askme for @radim').save        # match
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th popokatepetl #tag4 about #askme for @ondra').save  # match
      
      result = MessageFindModel.new(:message=>"pokat").find
      assert_equal(result.size, 2)
      
      result = MessageFindModel.new(:message=>"popo").find
      assert_equal(result.size, 2)
      
      result = MessageFindModel.new(:message=>"kate").find
      assert_equal(result.size, 2)
    end

    should('find two records by a tag') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #message about #askme for @ondra').save  # match
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #message about #askme for @radim').save  # match
      
      result = MessageFindModel.new(:tags=>['askme']).find

      assert_equal(result.size, 2)
    end

    should('find one record by tags') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra').save     # match
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim').save
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about #askme for @radim').save
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th #tag4 about #askme for @ondra').save

      MessageCreateModel.new(:id=>5, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about for @ondra').save
      MessageCreateModel.new(:id=>6, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about for @radim').save
      MessageCreateModel.new(:id=>7, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about for @radim').save
      MessageCreateModel.new(:id=>8, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th #tag4 about for @ondra').save
      
      result = MessageFindModel.new(:tags=>['tag1', 'askme']).find

      assert_equal(result.size, 1)
    end

    should('find three records by an author and recipients and a thread_id') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra').save     # match
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim').save
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about #askme for @jaromir').save   # match
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th #tag4 about #askme for @ondra').save

      MessageCreateModel.new(:id=>5, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about for @ondra').save            # match
      MessageCreateModel.new(:id=>6, :thread_id=>2, :author=>'ondra', :message=>'this is the 2nd #tag2 about for @radim').save
      MessageCreateModel.new(:id=>7, :thread_id=>2, :author=>'radim', :message=>'this is the 3rd #tag3 about for @radim').save
      MessageCreateModel.new(:id=>8, :thread_id=>2, :author=>'jaromir', :message=>'this is the 4th #tag4 about for @ondra').save
      
      result = MessageFindModel.new(:authors=>['radim'], :recipients=>['ondra', 'jaromir'], :thread_ids=>[1]).find

      assert_equal(result.size, 3)
    end
    
    should('find one record by an author and a tag') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #message about #askme for @ondra').save  # match
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #message about #askme for @radim').save
      
      result = MessageFindModel.new(:authors=>['radim'], :tags=>['askme']).find

      assert_equal(result.size, 1)
    end

    should('find two records by a string and a tag and a recipient parsed from the message') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra').save     # match
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim').save
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about #askme for @jaromir').save
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th #tag4 about #askme for @ondra').save

      MessageCreateModel.new(:id=>5, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about for @ondra').save            # match
      MessageCreateModel.new(:id=>6, :thread_id=>2, :author=>'ondra', :message=>'this is the 2nd #tag2 about for @radim').save
      MessageCreateModel.new(:id=>7, :thread_id=>2, :author=>'radim', :message=>'this is the 3rd #tag3 about for @radim').save
      MessageCreateModel.new(:id=>8, :thread_id=>2, :author=>'jaromir', :message=>'this is the 4th #tag4 about for @ondra').save
      
      MessageCreateModel.new(:id=>6, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about for @jaromir').save

      result = MessageFindModel.new(:message=>"about #tag1 @ondra").find

      assert_equal(result.size, 2)
    end

    should('find one record by a rank') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra', :rank=>1).save
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim', :rank=>2).save
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about #askme for @jaromir', :rank=>3).save # match
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th #tag4 about #askme for @ondra', :rank=>4).save

      result = MessageFindModel.new(:rank=>[3]).find

      assert_equal(result.size, 1)
    end

    should('find three records by a rank and a rank tolerance') do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #tag1 about #askme for @ondra', :rank=>1).save   # match
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #tag2 about #askme for @radim', :rank=>2).save   # match
      MessageCreateModel.new(:id=>3, :thread_id=>1, :author=>'radim', :message=>'this is the 3rd #tag3 about #askme for @jaromir', :rank=>3).save # match
      MessageCreateModel.new(:id=>4, :thread_id=>1, :author=>'jaromir', :message=>'this is the 4th #tag4 about #askme for @ondra', :rank=>4).save

      result = MessageFindModel.new(:rank=>[2, 1]).find

      assert_equal(result.size, 3)
    end

  end

end

# vim:ff=unix ts=2 ss=2 sts=2 et
