# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:

    # NearSpecial criterion is used when performing #near with symbols to get
    # get a shorthand syntax for where clauses.
    #
    # @example Coninputersion of a simple to complex criterion.
    #   { :field => { "$nearSphere" => => [20,30]}, '$maxDistance' => 5 }
    #   becomes:
    #   { :field.near(:sphere) => {:point => [20,30], :max => 5, :unit => :km} }
    class NearSpacial < Complex

      # Coninputert input to query for near or nearSphere
      #
      # @example
      #   near = NearSpacial.new(:key => :field, :operator => "near")
      #   near.to_mongo_query({:point => [:50,50], :max => 5, :unit => :km}) => { '$near : [50,50]' , '$maxDistance' : 5 }
      #
      # @param [Hash,Array] input input to coninputer to query
      def to_mongo_query(input)
        if input.kind_of?(Hash)
          raise ':point required to make valid query' unless input[:point]
          input[:point] = input[:point].to_lng_lat if input[:point].respond_to?(:to_lng_lat)
          query = {"$#{operator}" => input[:point] }
          if input[:max]
            query['$maxDistance'] = input[:max].to_f

            if unit = Mongoid::Spacial.earth_radius[input[:unit]]
              unit *= Mongoid::Spacial::RAD_PER_DEG unless operator =~ /sphere/i
              input[:unit] = unit
            end

            query['$maxDistance'] = query['$maxDistance']/input[:unit].to_f if input[:unit]
          end
          query
        elsif input.kind_of? Array
          if input.first.kind_of? Numeric
            {"$#{operator}" => input }
          else
            input[0] = input[0].to_lng_lat if input[0].respond_to?(:to_lng_lat)
            {"$#{operator}" => input[0], '$maxDistance' => input[1] }
          end
        end
      end

    end
  end
end

