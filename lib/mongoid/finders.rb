module Mongoid #:nodoc:
  module Finders
    delegate :geo_near, :to => :criteria 
  end
end
