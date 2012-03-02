# encoding: utf-8
# author: rpolasek

require './test/test_helper'

class ElasticSearchAdapterTest < Test::Unit::TestCase
  
  context 'elasticsearch adapter' do

    setup do
      ElasticSearchAdapter.index = 'askme_test'

      Tire.index ElasticSearchAdapter.index do
        delete
        create
      end
    end
 
    should 'found no records' do
      assert_equal(MessageFindModel.new(:ids => [1]).find.empty?, true)
    end
    
    should 'create just one message' do
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

    should 'create next message and update it' do
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

    should 'find two records by tag' do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #message about #askme for @ondra').save
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #message about #askme for @radim').save
      
      result = MessageFindModel.new(:tags=>['askme']).find

      assert_equal(result.size, 2)
    end

    should 'find two record by author and tag' do
      MessageCreateModel.new(:id=>1, :thread_id=>1, :author=>'radim', :message=>'this is the 1st #message about #askme for @ondra').save
      MessageCreateModel.new(:id=>2, :thread_id=>1, :author=>'ondra', :message=>'this is the 2nd #message about #askme for @radim').save
      
      result = MessageFindModel.new(:author=>'radim', :tags=>['askme']).find

      assert_equal(result.size, 2)
    end

  end

end

# vim:ff=unix ts=2 ss=2 sts=2 et
