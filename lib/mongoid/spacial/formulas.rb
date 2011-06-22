module Mongoid
  module Spacial
    module Formulas
      RAD_PER_DEG = 0.017453293

      def n_vector(p1,p2)
        sin_x1 = Math.sin(p1[0])
        cos_x1 = Math.cos(p1[0])

        sin_y1 = Math.sin(p1[1])
        cos_y1 = Math.cos(p1[1])

        sin_x2 = Math.sin(p2[0])
        cos_x2 = Math.cos(p2[0])

        sin_y2 = Math.sin(p2[1])
        cos_y2 = Math.cos(p2[1])

        cross_prod =  (cos_y1*cos_x1 * cos_y2*cos_x2) +
          (cos_y1*sin_x1 * cos_y2*sin_x2) +
          (sin_y1        * sin_y2)
        Math.acos(cross_prod)
      end

      def haversine(p1,p2)
        lon1,lat1=p1
        lon2,lat2=p2

        dlon = lon2 - lon1
        dlat = lat2 - lat1

        dlon_rad = dlon * RAD_PER_DEG
        dlat_rad = dlat * RAD_PER_DEG

        lat1_rad = lat1 * RAD_PER_DEG
        lon1_rad = lon1 * RAD_PER_DEG

        lat2_rad = lat2 * RAD_PER_DEG
        lon2_rad = lon2 * RAD_PER_DEG

        a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2

        2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
      end
    end
  end
end
