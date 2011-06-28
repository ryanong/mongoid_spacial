require "spec_helper"

describe Mongoid::Spacial do
  describe '#distance' do
    it "should calculate 2d by default" do
      Mongoid::Spacial.distance([0,0],[3,4]).should == 5
    end

    it "should calculate 2d distances using degrees" do
      Mongoid::Spacial.distance([0,0],[3,4], :unit=>:mi).should == 5*Mongoid::Spacial::EARTH_RADIUS[:mi]*Mongoid::Spacial::RAD_PER_DEG
    end

    it "should calculate 3d distances by default" do
      Mongoid::Spacial.distance([-73.77694444, 40.63861111 ],[-118.40, 33.94],:unit=>:mi, :spherical => true).to_i.should be_within(1).of(2469)
    end
  end
end

