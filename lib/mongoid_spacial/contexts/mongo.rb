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
        opts = self.options.merge(opts)
        # convert point
        center = center.to_lng_lat if center.respond_to?(:to_lng_lat)

        # set default opts
        opts[:skip] ||= 0

        if unit = Mongoid::Spacial.earth_radius[opts[:unit]]
          opts[:unit] = (opts[:spherical]) ? unit : unit * Mongoid::Spacial::RAD_PER_DEG
        end

        if unit = Mongoid::Spacial.earth_radius[opts[:distance_multiplier]]
          opts[:distance_multiplier] = (opts[:spherical]) ? unit : unit * Mongoid::Spacial::RAD_PER_DEG
        end

        opts[:distance_multiplier] = opts[:unit] if opts[:unit].kind_of?(Numeric)

        # setup paging.
        if opts.has_key?(:page)
          opts[:page] ||= 1
          opts[:paginator] ||= Mongoid::Spacial.paginator()

           if opts[:per_page].blank?
             opts[:per_page] = case opts[:paginator]
                              when :will_paginate
                                @document.per_page
                              when :kaminari
                                Kaminari.config.default_per_page
                              else
                                Mongoid::Spacial.default_per_page
                              end
           end

        end
        opts[:query] = create_geo_near_query(center,opts)
        results = klass.db.command(opts[:query])
        Mongoid::Spacial::GeoNearResults.new(klass,results,opts)
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
          query['num']         = opts[:skip].to_i + opts[:num].to_i
        elsif opts[:limit]
          query['num']         = opts[:skip].to_i + opts[:limit].to_i
        elsif opts[:page]
          query['num'] = opts[:skip].to_i + (opts[:page].to_i * opts[:per_page].to_i)
        end

        # allow the use of complex werieis
        if opts[:query]
          query['query']         = self.criteria.where(opts[:query]).selector
        elsif self.selector != {}
          query['query']         = self.selector
        end

        if opts[:max_distance]
          query['maxDistance'] = opts[:max_distance].to_f
          query['maxDistance'] = query['maxDistance']/opts[:unit].to_f if opts[:unit]
        end

        if klass.db.connection.server_version >= '1.7'
          query['spherical']  = true if opts[:spherical]

          # mongodb < 1.7 returns degrees but with earth flat. in Mongodb 1.7 you can set sphere and let mongodb calculate the distance in Miles or KM
          # for mongodb < 1.7 we need to run Haversine first before calculating degrees to Km or Miles. See below.
          query['distanceMultiplier'] = opts[:distance_multiplier].to_f if opts[:distance_multiplier]
        end
        query
      end
    end
  end
end
