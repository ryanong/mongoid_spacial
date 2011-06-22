# encoding: utf-8
module Mongoid #:nodoc:
  module Extensions #:nodoc:
    module Hash #:nodoc:
      module CriteriaHelpers #:nodoc:
        def expand_complex_criteria
          hsh = {} 
          each_pair do |k,v|
            if k.respond_to?(:key) && k.respond_to?(:to_mongo_query)
              hsh[k.key] ||= {}
              hsh[k.key].merge!(k.to_mongo_query(v))
            else
              hsh[k] = v
            end
          end
          hsh
        end
      end
    end
  end
end

