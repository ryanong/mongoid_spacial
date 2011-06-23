require "spec_helper"

describe Mongoid::Spacial::Formulas do
    context "#n_vector" do
      it {
        bna = [-86.67, 36.12]
        lax = [-118.40, 33.94]
        dist1 = Mongoid::Spacial::Formulas.n_vector(bna, lax)
        dist2 = Mongoid::Spacial::Formulas.n_vector(lax, bna)

        # target is 0.45306
        dist1.should be_within(0.00001).of(0.45306)
        dist2.should be_within(0.00001).of(0.45306)
      }
      it {
        # actual distance 2471.788
        jfk = [-73.77694444, 40.63861111 ]
        lax = [-118.40, 33.94]

        dist = Mongoid::Spacial::Formulas.n_vector(jfk, lax) * Mongoid::Spacial.earth_radius[:mi]
        dist.should be_within(1).of(2469)
      }
    end

    context "#haversine" do
      it {
        # actual distance 2471.788
        jfk = [-73.77694444, 40.63861111 ]
        lax = [-118.40, 33.94]

        dist = Mongoid::Spacial::Formulas.haversine(jfk, lax) * Mongoid::Spacial.earth_radius[:mi]
        dist.should be_within(1).of(2469)
      }
    end

end

