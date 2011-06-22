module Mongoid #:nodoc:
  class Criteria
    delegate :geo_near, :to => :context 
  end
end
