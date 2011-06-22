require "spec_helper"

describe Mongoid::Contexts::Mongo do

  before do
    Bar.delete_all
    Bar.create_indexes
  end
  
  let!(:munich) do
    Bar.create(:location => [45, 11], :name => 'Munich')
  end

  let!(:berlin) do
    Bar.create(:location => [46, 12], :name => 'Berlin')
  end
  describe "geo_near" do
    it "should work with specifying specific center and different location attribute on collction" do
      location = [-47,23.5]
      near = Bar.geo_near(location)
      near.should == [munich,berlin]
      near.first.geo[:distance].should > 0
    end

    describe 'option :num' do
      it "should limit number of results to 1" do
        location = [-47,23.5]
        Bar.geo_near(location, :num => 1).size.should == 1
      end
    end
    
    describe 'option :maxDistance' do
      it "should limit on maximum distance" do
        location = [45.1, 11.1]
        # db.runCommand({ geo_near : "points", near :[45.1, 11.1]}).results;
        # dis: is 0.14141869255648362  and  1.2727947855285668 
        Bar.geo_near(location, :max_distance => 0.2).should == [munich]
      end
    end
    
    describe 'option :distanceMultiplier' do
      it "should multiply returned distance with multiplier" do
        location = [45.1, 11.1]
        Bar.geo_near(location, :distance_multiplier => 4).first.geo[:distance].should > 0
      end
    end
    
    describe 'option :unit' do
      it "should multiply returned distance with multiplier" do
        location = [45.1, 11.1]
        distance = Bar.geo_near(location, :unit => :mi).first.geo[:distance]
        distance.should > 559
        distance.should < 560
      end

      it "should convert max_distance to radians with unit" do
        location = [45.1, 11.1]
        near = Bar.geo_near(location, :max_distance => 570, :unit => :mi)
        near.size.should == 1
        near.first.should == munich
      end

      it "should convert max_distance to radians with unit" do
        location = [45.1, 11.1]
        Bar.geo_near(location, :max_distance => 570, :distance_multiplier => 4, :unit => :mi).first.should == munich
      end

    end

    describe 'option :query' do
      it "should filter using extra query option" do
        location = [45.1, 11.1]
        # two record in the collection, only one's name is Munich
        Bar.geo_near(location, :query => {:name => 'Munich'}).size.should == 1
      end
    end

    describe 'criteria chaining' do
      it "should filter by where" do
        location = [45.1, 11.1]
        # two record in the collection, only one's name is Munich
        a = Bar.where(:name => 'Munich')
        # p a.selector
        # a.geo_near(location).size.should == 1
      end

      it 'should skip 1' do
        location = [-47,23.5]
        Bar.skip(1).geo_near(location).size.should == 1
      end

      it 'should limit 1' do
        location = [-47,23.5]
        Bar.limit(1).geo_near(location).size.should == 1
      end

    end

  end
end

