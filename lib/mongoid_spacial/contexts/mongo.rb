# encoding: utf-8
module Mongoid #:nodoc:
  module Contexts #:nodoc:
    class Mongo #:nodoc:
      
      # Fetches rows from the data base sorted by distance.
      # In MongoDB versions 1.7 and above it returns a distance.
      # Uses all criteria chains except without, only, asc, desc, order_by
      #
      # @example Minimal Query
      #   
      #   Address.geo_near([70,40])
      #
      # @example Chained Query
      #   
      #   Address.where(:state => 'ny').geo_near([70,40])
      #
      # @example Calc Distances Query
      #   
      #   Address.geo_near([70,40], :max_distance => 5, :unit => 5)
      #
      # @param [ Array, Hash, #to_lng_lat ] center The center of where to calculate distance from
      # @param [ Hash ] opts the options to query with
      # @options opts [Integer] :num The number of rows to fetch
      # @options opts [Hash] :query The query to filter the rows by, accepts
      # @options opts [Numeric] :distance_multiplier this is multiplied against the calculated distance
      # @options opts [Numeric] :max_distance The max distance of a row that should be returned in :unit(s)
      # @options opts [Numeric, :km, :k, :mi, :ft] :unit automatically sets :distance_multiplier and converts :max_distance
      # @options opts [true,false] :spherical Will determine the distance either by spherical calculation or flat calculation
      # @options opts [TrueClass,Array<Symbol>] :calculate Which extra fields to calculate distance for in ruby, if set to TrueClass it will calculate all spacial fields
      #
      # @return [ Array ] Sorted Rows
      def geo_near(center, opts = {})
        center = center.to_lng_lat if center.respond_to?(:to_lng_lat)

        if distance_multiplier = Mongoid::Spacial.earth_radius[opts.delete(:unit)]
          opts[:distance_multiplier] = distance_multiplier
        end

        query = create_geo_near_query(center,opts)
        results = klass.db.command(query)
        if results['results'].kind_of?(Array) && results['results'].size > 0
          rows = results['results'].collect do |result|
            res = Mongoid::Factory.from_db(klass, result.delete('obj'))
            res.geo = {}
            # camel case is awkward in ruby when using variables...
            if result['dis']
              res.geo[:distance] = result.delete('dis').to_f
            end
            result.each do |key,value|
              res.geo[key.snakecase.to_sym] = value
            end
            # dist_options[:formula] = opts[:formula] if opts[:formula]
            opts[:calculate] = klass.spacial_fields_indexed if klass.spacial_fields_indexed.kind_of?(Array) && opts[:calculate] == true
            if opts[:calculate]
              opts[:calculate] = [opts[:calculate]] unless opts[:calculate].kind_of? Array
              opts[:calculate] = opts[:calculate].map(&:to_sym) & geo_fields
              if klass.spacial_fields_indexed.kind_of?(Array) && klass.spacial_fields_indexed.size == 1
                primary = klass.spacial_fields_indexed.first
              end
              opts[:calculate].each do |key|
                key = (key.to_s+'_distance').to_s
                res.geo[key] = res.distance_from(key,center, opts[:distance_multiplier])
                res.geo[:distance] = res.geo[key] if primary && key == primary
              end
            end
            res
          end
        else
          rows = []
        end
        # if opts.has_key?(:page) || opts[:paginator]
        #   opts[:paginator] ||= Mongoid::Spacial::Config.paginator
        #   if opts[:paginator] == :kaminari

        #   elsif opts[:paginator] == :will_paginate
        #   end
        # end

        if self.options[:skip] && rows.size > self.options[:skip]
          rows[self.options[:skip]..rows.size-1]
        else
          rows
        end
      end

      private

      def create_geo_near_query(center,opts)
        # minimum query
        query = {
          :geoNear  => klass.to_s.tableize,
          :near     => center, 
        }

        # create limit and use skip
        if opts[:num] 
          query['num']         = (self.options[:skip] || 0) + opts[:num].to_i          
        elsif self.options[:limit]
          query['num']         = (self.options[:skip] || 0) + self.options[:limit]
        end

        # allow the use of complex werieis
        if opts[:query]
          query['query']         = self.criteria.where(opts[:query]).selector
        elsif self.selector != {}
          query['query']         = self.selector
        end

        if opts[:max_distance]
          query['maxDistance'] = opts[:max_distance]
          query['maxDistance'] = query['maxDistance']/opts[:distance_multiplier] if opts[:distance_multiplier]
        end

        if klass.db.connection.server_version >= '1.7'          
          query['spherical']  = true if opts[:spherical]

          # mongodb < 1.7 returns degrees but with earth flat. in Mongodb 1.7 you can set sphere and let mongodb calculate the distance in Miles or KM
          # for mongodb < 1.7 we need to run Haversine first before calculating degrees to Km or Miles. See below.
          query['distanceMultiplier'] = opts[:distance_multiplier] if opts[:distance_multiplier]
        end
        query
      end
    end
  end
end
