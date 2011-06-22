module Mongoid
  module Spacial
    module Document 
      extend ActiveSupport::Concern

      included do
        attr_accessor :geo
        mattr_accessor :spacial_fields, :spacial_fields_indexed
        @@spacial_fields = []
        @@spacial_fields_indexed = []
      end

      module ClassMethods #:nodoc:
        def spacial_index name, options = {}
          @@spacial_fields_indexed << name.to_sym
          index [[ name, Mongo::GEO2D ]], options
        end
      end

      module InstanceMethods
        def distance_from(key,center, unit = nil, formula = nil)
          loc = res.send(key)
          Mongoid::Spacial.distance(center, loc, unit, formula = nil)
        end
      end
    end
  end
end
