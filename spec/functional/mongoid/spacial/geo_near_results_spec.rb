require "spec_helper"

describe Mongoid::Spacial::GeoNearResults do
  before(:all) do
    Bar.delete_all
    Bar.create_indexes

    50.times do
      Bar.create({:location => [rand(360)-180,rand(360)-180]})
    end
    while Bar.count < 50
    end
  end
  context ":paginator :array" do
    [nil,1,2].each do |page|          
      it "page=#{page} should have 25" do
        Bar.geo_near([1,1]).page(page).size.should == 25
      end
    end

    it "page=3 should have 0" do
      Bar.geo_near([1,1]).page(3).size.should == 0
    end

    it "per=5" do
      Bar.geo_near([1,1]).per(5).size.should == 5
    end
  end

  context ":paginator :kaminari" do 
    let!(:near) {Bar.geo_near([1,1]).page(1)}
    it "should have current_page" do
      near.current_page.should == 1
    end

    it "should have num_pages" do
      near.total_entries.should == 50
      near.num_pages.should == 2
    end

    it "should have limit_value" do
      near.limit_value.should == 25
    end
  end
end
