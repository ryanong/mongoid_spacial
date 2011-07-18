require "spec_helper"

describe Mongoid::Spacial::GeoNearResults do
  before(:all) do
    Bar.delete_all
    Bar.create_indexes

    50.times do |i|
      Bar.create(:name => i.to_s, :location => [rand(358)-179,rand(358)-179])
    end
  end

  before(:each) do
    while Bar.count < 50
    end
  end

  context ":paginator :array" do
    let!(:bars) { Bar.geo_near([1,1]) }
    let!(:sorted_bars) { Bar.geo_near([1,1]).sort_by {|b| b.name.to_i}}
    [nil,1,2].each do |page|
      it "page=#{page} should have 25" do
        bars.page(page).size.should == 25
      end
    end

    [1,2].each do |page|
      it "modified result should keep order after pagination" do
        sorted_bars.page(page).should == sorted_bars.slice((page-1)*25,25)
      end
    end

    { nil => 25, 20 => 20 , 30 => 20, 50 => 0}.each do |per, total|
      it "page=2 per=#{per} should have #{total}" do
        bars.per(per).page(2).size.should == total
        bars.page(2).per(per).size.should == total
      end
    end

    it "page=3 should have 0" do
      bars.page(3).size.should == 0
    end

    it "per=5" do
      bars.per(5).size.should == 5
    end

    it "page=10 per=5" do
      bars.per(5).page(10).should == bars[45..50]
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
