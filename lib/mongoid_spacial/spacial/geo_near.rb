module Mongoid
  module Spacial
    class GeoNear < Array
      attr_reader :stats, :document
      attr_accessor :opts, :total_entries

      def initialize(document,results,opts = {})
        raise "class must include Mongoid::Spacial::Document" unless klass.respond_to?(:spacial_fields_indexed)
        @document = document
        @opts = opts
        @stats = results['stats']
        @opts['total_entries'] = @stats['nscanned']

        @_original_array = results['results'].collect do |result|
          res = Mongoid::Factory.from_db(@document, result.delete('obj'))
          res.geo = {}
          # camel case is awkward in ruby when using variables...
          if result['dis']
            res.geo[:distance] = result.delete('dis').to_f
          end
          result.each do |key,value|
            res.geo[key.snakecase.to_sym] = value
          end
          # dist_options[:formula] = opts[:formula] if opts[:formula]
          @opts[:calculate] = @document.spacial_fields_indexed if @document.spacial_fields_indexed.kind_of?(Array) && @opts[:calculate] == true
          if @opts[:calculate]
            @opts[:calculate] = [@opts[:calculate]] unless @opts[:calculate].kind_of? Array
            @opts[:calculate] = @opts[:calculate].map(&:to_sym) & geo_fields
            if @document.spacial_fields_indexed.kind_of?(Array) && @document.spacial_fields_indexed.size == 1
              primary = @document.spacial_fields_indexed.first
            end
            @opts[:calculate].each do |key|
              key = (key.to_s+'_distance').to_sym
              res.geo[key] = res.distance_from(key,center, @opts[:distance_multiplier])
              res.geo[:distance] = res.geo[key] if primary && key == primary
            end
          end
          res
        end

        if @opts[:page]
          start = (@opts[:page]-1)*@opts[:per_page] # assuming current_page is 1 based.
          super(@_original_array[start, @opts[:per_page]] || [])
        elsif @opts[:skip] && @_original_array.size > @opts[:skip]
          super(@_original_array[@opts[:skip]..-1] || [])
        else
          super(@_original_array || [])
        end
      end

      def current_page
        @opts[:page]
      end

      def num_pages
        total_entries/@opts[:per_page]
      end
      alias_method :total_pages, :num_pages

      def out_of_bounds?
        current_page > total_pages
      end

      def limit_value
        @opts[:per_page]
      end
      alias_method :per_page, :limit_value

      def offset
        (current_page - 1) * per_page
      end

      # current_page - 1 or nil if there is no previous page
      def previous_page
        current_page > 1 ? (current_page - 1) : nil
      end

      # current_page + 1 or nil if there is no next page
      def next_page
        current_page < total_pages ? (current_page + 1) : nil
      end

      def total_entries
        @opts['total_entries']
      end
    end
  end
end
