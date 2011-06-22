require 'mongoid/criterion/complex'
# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:
    autoload :Near_Spacial,     'mongoid/criterion/near_spacial'
    autoload :Within_Spacial,    'mongoid/criterion/within_spacial'
  end
end
