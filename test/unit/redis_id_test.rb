# -*- encoding : utf-8 -*-
require './test/test_helper'
class RedisIdTest < Test::Unit::TestCase
  context "RedisId for models" do
    setup do
      Database.redis.flushdb
    end
    
    should "return valid id" do
      assert_equal RedisId.get(:user), 1
      assert_equal RedisId.get(:user), 2
      assert_equal RedisId.get(:user), 3
      assert_equal RedisId.get(:message), 1
      assert_equal RedisId.get(:message), 2
      assert_equal RedisId.get(:message), 3
    end

    should "be setted and return then valid id" do
      assert RedisId.set(:user, 10)
      assert_equal RedisId.get(:user), 11
    end
    
    should "not raise exception when model name is provided" do
      assert_nothing_raised { RedisId.get(:tag) }
    end
    
    should "raise exception when no model name is provided" do
      assert_raises ArgumentError do
        RedisId.get()
      end
    end
  end
end