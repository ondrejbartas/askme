# encoding: utf-8
# author: rpolasek

class ElasticSearchError < StandardError
end

# create
class ElasticSearchCreateError < ElasticSearchError
end

# find
class ElasticSearchFindError < ElasticSearchError
end

# update
class ElasticSearchUpdateError < ElasticSearchError
end
