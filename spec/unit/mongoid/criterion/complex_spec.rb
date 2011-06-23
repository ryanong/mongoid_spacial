require "spec_helper"

describe Mongoid::Criterion::Complex do

  let(:complex) { Mongoid::Criterion::Complex.new(:key => :field, :operator => "gt") }

  let(:value) { 40 }

  context "#to_mongo_query" do
    it "should turn value into appropriate query" do
      complex.to_mongo_query(value).should == {"$gt" => value}
    end
  end

end
