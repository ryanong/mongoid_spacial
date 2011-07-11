module Mongoid
  module Spacial
    class GeoNearResults < Array
      attr_reader :stats, :document, :_original_array
      attr_accessor :opts

      def initialize(document,results,opts = {})
        raise "class must include Mongoid::Spacial::Document" unless document.respond_to?(:spacial_fields_indexed)
        @document = document
        @opts = opts
        @stats = results['stats'] || {}
        @opts[:skip] ||= 0
        @opts[:total_entries] = opts[:query]["num"] || @stats['nscanned']
        @limit_value = opts[:per_page]
        @current_page = opts[:page]

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
          super(@_original_array[@opts[:skip]+start, @opts[:per_page]] || [])
        else
          super(@_original_array[@opts[:skip]..-1] || [])
        end
      end

      def page(page, options = {})
        new_collection = self.dup

        options = self.opts.merge(options)

        options[:page] = (page) ? page.to_i : 1

        options[:paginator] ||= Mongoid::Spacial.paginator()

        options[:per_page] ||= case options[:paginator]
                            when :will_paginate
                              @document.per_page
                            when :kaminari
                              Kaminari.config.default_per_page
                            else
                              Mongoid::Spacial.default_per_page
                            end

        options[:per_page] = options[:per_page].to_i

        start = (options[:page]-1)*options[:per_page] # assuming current_page is 1 based.
        new_collection.replace(@_original_array[@opts[:skip]+start, options[:per_page]] || [])

        new_collection.opts[:page] = options[:page]
        new_collection.opts[:paginator] = options[:paginator]
        new_collection.opts[:per_page] = options[:per_page]

        new_collection
      end

      def per(num)
        self.page(current_page, :per_page => num)
      end

      def total_entries
        @opts[:total_entries]
      end

      def current_page
        @opts[:page]
      end

      def limit_value
        @opts[:per_page]
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
