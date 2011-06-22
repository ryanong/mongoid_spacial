require 'mongoid/spacial/core_ext'
module Mongoid
  module Spacial

    autoload :Formulas,          'mongoid/spacial/formulas'
    autoload :Document,          'mongoid/spacial/document'

    EARTH_RADIUS_KM = 6371 # taken directly from mongodb

    EARTH_RADIUS = {
      :km => EARTH_RADIUS_KM,
      :m  => EARTH_RADIUS_KM*1000,
      :mi => EARTH_RADIUS_KM*0.621371192, # taken directly from mongodb
      :ft => EARTH_RADIUS_KM*5280*0.621371192,
    }
    
    LNG_SYMBOLS = [:x, :lon, :long, :lng, :longitude]
    LAT_SYMBOLS = [:y, :lat, :latitude]

    def distance(p1,p2,unit = nil, formula = nil)
      formula ||= self.distance_formula
      unit = EARTH_RADIUS[unit] if unit.kind_of?(Symbol) && EARTH_RADIUS[unit]
      rads = Formulas.send(formula, p1, p2)
      (unit.kind_of?(Numeric)) ? unit*rads : rads
    end

    mattr_accessor :distance_formula
    @@distance_formula = :n_vector
  end
end
