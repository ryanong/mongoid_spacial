require "spec_helper"

describe Mongoid::Criterion::WithinSpacial do

  let(:within) do
    {
      :box => Mongoid::Criterion::WithinSpacial.new(:key => :field, :operator => "box"),
      :polygon => Mongoid::Criterion::WithinSpacial.new(:key => :field, :operator => "polygon"),
      :center => Mongoid::Criterion::WithinSpacial.new(:key => :field, :operator => "center"),
      :center_sphere => Mongoid::Criterion::WithinSpacial.new(:key => :field, :operator => "box"),
    }
  end
  WITHIN = {
    :box =>
    {
      'Array of Arrays' => [[10,20], [15,25]],
      'Array of Hashes' => [{ x: 10, y: 20 }, { x: 15, y: 25 }],
      'Hash of Hashes'  => { a: { x: 10, y: 20 }, b: { x: 15, y: 25 }}
    },
      :polygon =>
    {
      'Array of Arrays' => [[10,20], [15,25]],
      'Array of Hashes' => [{ x: 10, y: 20 }, { x: 15, y: 25 }],
      'Hash of Hashes'  => { a: { x: 10, y: 20 }, b: { x: 15, y: 25 }}
    },
      :center =>
    {
      'Point'           => [[1,2],5],
      'Hash Point'      => {:point => [-73.98, 40.77], :max => 5},
      'Hash Point Unit' => {:point => [-73.98, 40.77], :max => 5, :unit => :km}
    },
      :center_sphere =>
    {
      'Point'           => [[1,2],5],
      'Hash Point'      => {:point => [-73.98, 40.77], :max => 5},
      'Hash Point Unit' => {:point => [-73.98, 40.77], :max => 5, :unit => :km}
    }
  }

  context "#to_mongo_query" do

    WITHIN.each do |shape, points|
      points.each do |input_name,input|
        it "#{shape} should generate a query with #{input_name}" do
          within[shape].to_mongo_query(input).should be_a_kind_of(Hash)
        end
      end
    end
  end

end

