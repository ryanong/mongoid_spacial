require 'mongoid_spacial/criterion/complex'
# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:
    autoload :NearSpacial,     'mongoid_spacial/criterion/near_spacial'
    autoload :WithinSpacial,    'mongoid_spacial/criterion/within_spacial'
  end
end
