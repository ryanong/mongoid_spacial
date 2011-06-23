require "spec_helper"

describe Mongoid::Contexts::Mongo do
  describe "#geo_near" do

    before do
      Bar.delete_all
      Bar.create_indexes
    end

    let!(:jfk) do
      Bar.create(:name => 'jfk', :location => [-73.77694444, 40.63861111 ])
    end

    let!(:lax) do
      Bar.create(:name => 'lax', :location => [-118.40, 33.94])
    end

    it "should work with specifying specific center and different location attribute on collction" do
      Bar.geo_near(lax.location, :spherical => true).should == [lax, jfk]
      Bar.geo_near(jfk.location, :spherical => true).should == [jfk, lax]
    end

    describe 'option :num' do
      it "should limit number of results to 1" do
        Bar.geo_near(jfk.location, :num => 1).size.should == 1
      end
    end

    describe 'option :maxDistance' do
      it "should get 1 item" do
        Bar.geo_near(lax.location, :spherical => true, :max_distance => 2465/Mongoid::Spacial.earth_radius[:mi]).size.should == 1
      end
      it "should get 2 items" do
        Bar.geo_near(lax.location, :spherical => true, :max_distance => 2480/Mongoid::Spacial.earth_radius[:mi]).size.should == 2
      end

    end

    describe 'option :distance_multiplier' do
      it "should multiply returned distance with multiplier" do
          Bar.geo_near(lax.location, :spherical => true, :distance_multiplier=> Mongoid::Spacial.earth_radius[:mi]).second.geo[:distance].to_i.should be_within(1).of(2469)
      end
    end

    describe 'option :unit' do
      it "should multiply returned distance with multiplier" do
          Bar.geo_near(lax.location, :spherical => true, :unit => :mi).second.geo[:distance].to_i.should be_within(1).of(2469)
      end

      it "should convert max_distance to radians with unit" do
          Bar.geo_near(lax.location, :spherical => true, :max_distance => 2465, :unit => :mi).size.should == 1
      end

    end

    describe 'option :query' do
      it "should filter using extra query option" do
        # two record in the collection, only one's name is Munich
        Bar.geo_near(jfk.location, :query => {:name => jfk.name}).should == [jfk]
      end
    end

    describe 'criteria chaining' do
      it "should filter by where" do
        Bar.where(:name => jfk.name).geo_near(jfk.location).should == [jfk]
        Bar.any_of({:name => jfk.name},{:name => lax.name}).geo_near(jfk.location).should == [jfk,lax]
      end

      it 'should skip 1' do
        Bar.skip(1).geo_near(jfk.location).size.should == 1
      end

      it 'should limit 1' do
        Bar.limit(1).geo_near(jfk.location).size.should == 1
      end

    end

  end
end

