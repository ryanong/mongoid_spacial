# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:

    # NearSpecial criterion is used when performing #near with symbols to get
    # get a shorthand syntax for where clauses.
    #
    # @example Conversion of a simple to complex criterion.
    #   { :field => { "$nearSphere" => => [20,30]}, '$maxDistance' => 5 }
    #   becomes:
    #   { :field.near(:sphere) => {:point => [20,30], :max => 5, :unit => :km} }
    class NearSpacial < Complex

      # Convert input to query for near or nearSphere
      #
      # @example
      #   near = NearSpacial.new(:key => :field, :operator => "near")
      #   near.to_mongo_query({:point => [:50,50], :max_distance => 5, :unit => :km}) => { '$near : [50,50]' , '$maxDistance' : 5 }
      #
      # @param [Hash,Array] v input to conver to query
      def to_mongo_query(v)
        if v.kind_of? Hash
          v[:point] = v[:point].to_lng_lat if v[:point].respond_to?(:to_lng_lat)
          query = {"$#{operator}" => v[:point] }
          if v[:max]
            if unit = Mongoid::Spacial.earth_radius[v[:unit]]
              unit *= Mongoid::Spacial::RAD_PER_DEG unless operator =~ /sphere/i
              query['$maxDistance'] = v[:max]/unit
            else
              query['$maxDistance'] = v[:max]
            end
          end
          query
        elsif v.kind_of? Array
          if v.first.kind_of? Numeric
            {"$#{operator}" => v }
          else
            v[0] = v[0].to_lng_lat if v[0].respond_to?(:to_lng_lat)
            {"$#{operator}" => v[0], '$maxDistance' => v[1] }
          end
        end
      end

    end
  end
end

