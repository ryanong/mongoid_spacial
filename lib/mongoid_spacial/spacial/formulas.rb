module Mongoid
  module Spacial
    module Formulas

      def self.n_vector(point1,point2)
        p1 = point1.map{|deg| deg * RAD_PER_DEG}
        p2 = point2.map{|deg| deg * RAD_PER_DEG}

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

        return cross_prod > 0 ? 0 : Math::PI if (cross_prod >= 1 || cross_prod <= -1) 

        Math.acos(cross_prod)
      end

      def self.haversine(point1,point2)
        p1 = point1.map{|deg| deg * RAD_PER_DEG}
        p2 = point2.map{|deg| deg * RAD_PER_DEG}

        dlon = p2[0] - p1[0]
        dlat = p2[1] - p1[1]

        a = (Math.sin(dlat/2))**2 + Math.cos(p1[1]) * Math.cos(p2[1]) * (Math.sin(dlon/2))**2

        2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
      end
    end
  end
end
