# encoding: utf-8
module Mongoid #:nodoc:
  module Criterion #:nodoc:
    module Inclusion
      def near(attributes = {})
        update_selector(attributes, "$near")
      end

      def near_sphere(attributes = {})
        update_selector(attributes, "$near")
      end
    end
  end
end
