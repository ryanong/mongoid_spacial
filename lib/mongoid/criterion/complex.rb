# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:
    # Complex criterion are used when performing operations on symbols to get
    # get a shorthand syntax for where clauses.
    #
    # Example:
    #
    # <tt>{ :field => { "$lt" => "value" } }</tt>
    # becomes:
    # <tt> { :field.lt => "value }</tt>
    class Complex
      
      def to_mongo_query v
        {"$#{operator}" => v}
      end
    end
  end
end
