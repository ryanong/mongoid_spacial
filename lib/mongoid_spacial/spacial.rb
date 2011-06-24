require 'mongoid_spacial/spacial/core_ext'
require 'mongoid_spacial/spacial/formulas'
require 'mongoid_spacial/spacial/document'
require 'mongoid_spacial/spacial/geo_near_results'
module Mongoid
  module Spacial

    EARTH_RADIUS_KM = 6371 # taken directly from mongodb

    EARTH_RADIUS = {
      :km => EARTH_RADIUS_KM,
      :m  => EARTH_RADIUS_KM*1000,
      :mi => EARTH_RADIUS_KM*0.621371192, # taken directly from mongodb
      :ft => EARTH_RADIUS_KM*5280*0.621371192,
    }

    RAD_PER_DEG = Math::PI/180

    LNG_SYMBOLS = [:x, :lon, :long, :lng, :longitude]
    LAT_SYMBOLS = [:y, :lat, :latitude]

    def self.distance(p1,p2,unit = nil, formula = nil)
      formula ||= @@distance_formula

      p1 = p1.to_lng_lat if p1.respond_to?(:to_lng_lat)
      p1 = p1.to_lng_lat if p1.respond_to?(:to_lng_lat)
      
      unit = earth_radius[unit] if unit.kind_of?(Symbol) && earth_radius[unit]
      rads = Formulas.send(formula, p1, p2)
      (unit.kind_of?(Numeric)) ? unit*rads : rads
    end

    mattr_accessor :lng_symbols
    @@lng_symbols = LNG_SYMBOLS.dup

    mattr_accessor :lat_symbols
    @@lat_symbols = LAT_SYMBOLS.dup

    mattr_accessor :earth_radius
    @@earth_radius = EARTH_RADIUS.dup

    mattr_accessor :distance_formula
    @@distance_formula = :n_vector

      mattr_accessor :paginator
      @@paginator = :array

    mattr_accessor :default_per_page
    @@default_per_page = 25
  end
end
