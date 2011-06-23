require "spec_helper"

describe Mongoid::Criterion::NearSpacial do

  let(:within) do
    {
      :flat => Mongoid::Criterion::WithinSpacial.new(:key => :field, :operator => "near"),
      :sphere => Mongoid::Criterion::WithinSpacial.new(:key => :field, :operator => "nearSphere"),
    }
  end
  NEAR = {
      :flat =>
    {
      'Point'           => [[1,2],5],
      'Hash Point'      => {:point => [-73.98, 40.77], :max => 5},
      'Hash Point Unit' => {:point => [-73.98, 40.77], :max => 5, :unit => :km}
    },
      :sphere =>
    {
      'Point'           => [[1,2],5],
      'Hash Point'      => {:point => [-73.98, 40.77], :max => 5},
      'Hash Point Unit' => {:point => [-73.98, 40.77], :max => 5, :unit => :km}
    }
  }

  context "#to_mongo_query" do

    NEAR.each do |shape, points|
      points.each do |input_name,input|
        it "#{shape} should generate a query with #{input_name}" do
          within[shape].to_mongo_query(input).should be_a_kind_of(Hash)
        end
      end
    end
  end

end


