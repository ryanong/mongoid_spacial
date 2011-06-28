# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:

    # WithinSpecial criterion is used when performing #within with symbols to get
    # get a shorthand syntax for where clauses.
    #
    # @example Conversion of a simple to complex criterion.
    #   { :field => { "$within" => {'$center' => [20,30]} } }
    #   becomes:
    #   { :field.within(:center) => [20,30] }
    class WithinSpacial < Complex

      # Convert input to query for box, polygon, center, and centerSphere
      #
      # @example
      #   within = WithinSpacial.new(opts[:key] => 'point', :operator => 'center')
      #   within.to_mongo_query({:point => [20,30], :max => 5, :unit => :km}) #=>
      #
      # @param [Hash,Array] input Variable to conver to query
      def to_mongo_query(input)
        if ['box','polygon'].index(@operator)
          input = input.values if input.kind_of?(Hash)
          if input.respond_to?(:map)
            input.map!{ |v| (v.respond_to?(:to_lng_lat)) ? v.to_lng_lat : v }
          else
            input
          end
        elsif ['center','centerSphere'].index(@operator)

          if input.kind_of?(Hash) || input.kind_of?(ActiveSupport::OrderedHash)
            raise ':point required to make valid query' unless input[:point]
            input[:point] = input[:point].to_lng_lat if input[:point].respond_to?(:to_lng_lat)
            if input[:max]
              input[:max] = input[:max].to_f

              if unit = Mongoid::Spacial.earth_radius[input[:unit]]
                unit *= Mongoid::Spacial::RAD_PER_DEG unless operator =~ /sphere/i
                input[:unit] = unit
              end

              input[:max] = input[:max]/input[:unit].to_f if input[:unit]

              input = [input[:point],input[:max]]
            else
              input = input[:point]
            end
          end

          if input.kind_of? Array
            input[0] = input[0].to_lng_lat if input[0].respond_to?(:to_lng_lat)
          end

        end
        {'$within' => {"$#{@operator}"=>input} }
      end
    end
  end
end

