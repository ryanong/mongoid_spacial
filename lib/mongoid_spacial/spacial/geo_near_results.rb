module Mongoid
  module Spacial
    class GeoNearResults < Array
      attr_reader :stats, :document, :_original_array, :_original_opts
      attr_accessor :opts

      def initialize(document,results,opts = {})
        raise "class must include Mongoid::Spacial::Document" unless document.respond_to?(:spacial_fields_indexed)
        @document = document
        @opts = opts
        @_original_opts = opts.clone
        @stats = results['stats'] || {}
        @opts[:skip] ||= 0
        @opts[:total_entries] = opts[:query]["num"] || @stats['nscanned']

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
              res.geo[key] = res.distance_from(key,center,{:unit =>@opts[:unit] || @opts[:distance_multiplier], :spherical => @opts[:spherical]} )
              res.geo[:distance] = res.geo[key] if primary && key == primary
            end
          end
          res
        end
        if @opts[:page]
          start = (@opts[:page]-1)*@opts[:per_page] # assuming current_page is 1 based.
          @_paginated_array = @_original_array.clone
          super(@_paginated_array[@opts[:skip]+start, @opts[:per_page]] || [])
        else
          super(@_original_array[@opts[:skip]..-1] || [])
        end
      end

      def page(page, options = {})
        new_collection = self.clone
        original = options.delete(:original)
        new_collection.opts.merge!(options)
        new_collection.opts[:paginator] ||= Mongoid::Spacial.paginator

        start = (new_collection.current_page-1)*new_collection.limit_value # assuming current_page is 1 based.

        if original
          @_paginated_array = @_original_array.clone
          new_collection.replace(@_original_array[new_collection.opts[:skip]+start, new_collection.limit_value] || [])
        else
          @_paginated_array ||= self.to_a
          new_collection.replace(@_paginated_array[new_collection.opts[:skip]+start, new_collection.limit_value])
        end

        new_collection
      end

      def per(num)
        self.page(current_page, :per_page => num)
      end

      def reset!
        self.replace(@_original_array)
        @opts = @_original_opts
        @_paginated_array = nil
        true
      end

      def reset
        clone = self.clone
        clone.reset!
        clone
      end

      def total_entries
        @opts[:total_entries]
      end

      def current_page
        page = (@opts[:page]) ? @opts[:page].to_i.abs : 1
        (@opts[:page] < 1) ? 1 : page
      end

      def limit_value
        if @opts[:per_page]
          @opts[:per_page] = @opts[:per_page].to_i.abs
        else
          @opts[:per_page] = case new_collection.opts[:paginator]
                             when :will_paginate
                               @document.per_page
                             when :kaminari
                               Kaminari.config.default_per_page
                             else
                               Mongoid::Spacial.default_per_page
                             end
        end
      end
      alias_method :per_page, :limit_value

      def num_pages
        @opts[:total_entries]/@opts[:per_page]
      end
      alias_method :total_pages, :num_pages

      def out_of_bounds?
        self.current_page > self.total_pages
      end

      def offset
        (self.current_page - 1) * self.per_page
      end

      # current_page - 1 or nil if there is no previous page
      def previous_page
        self.current_page > 1 ? (self.current_page - 1) : nil
      end

      # current_page + 1 or nil if there is no next page
      def next_page
        self.current_page < self.total_pages ? (self.current_page + 1) : nil
      end

    end
  end
end
