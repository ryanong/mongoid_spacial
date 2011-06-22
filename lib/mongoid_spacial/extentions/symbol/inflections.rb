# encoding: utf-8
module Mongoid #:nodoc:
  module Extensions #:nodoc:
    module Symbol #:nodoc:
      module Inflections #:nodoc:

        # return a class that will accept a value to convert the query correctly for near
        #
        # @param [Symbol] calc This accepts :sphere
        #
        # @return [Criterion::NearSpacial]

        def near(calc = :flat)
          Criterion::NearSpacial.new(:operator => get_op('near',calc), :key => self)          
        end

        # alias for self.near(:sphere)
        #
        # @return [Criterion::NearSpacial]
        def near_sphere
          self.near(:sphere)
        end
        
        # @param [Symbol] shape :box,:polygon,:center,:center_sphere
        #
        # @return [Criterion::WithinSpacial]
        def within(shape)
          shape = get_op(:center,:sphere) if shape == :center_sphere
          Criterion::WithinSpacial.new(:operator => shape.to_s , :key => self)
        end

        private

        def get_op operator, calc
          if calc.to_sym == :sphere && Mongoid.master.connection.server_version >= '1.7'
            "#{operator}Sphere"
          elsif calc.to_sym == :sphere
            raise "MongoDB Server version #{Mongoid.master.connection.server_version} does not have Spherical Calculation"
          else
            operator.to_s
          end
        end
      end
    end
  end
end
