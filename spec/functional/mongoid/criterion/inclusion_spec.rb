require "spec_helper"

describe Mongoid::Criterion::Inclusion do

  before do
    Person.delete_all
  end

  describe "#where" do

    let(:dob) do
      33.years.ago.to_date
    end

    let(:lunch_time) do
      30.minutes.ago
    end

    let!(:person) do
      Person.create(
        :title => "Sir",
        :dob => dob,
        :lunch_time => lunch_time,
        :age => 33,
        :aliases => [ "D", "Durran" ],
        :things => [ { :phone => 'HTC Incredible' } ]
      )
    end

    context "when providing 24 character strings" do

      context "when the field is not an id field" do

        let(:string) do
          BSON::ObjectId.new.to_s
        end

        let!(:person) do
          Person.create(:title => string)
        end

        let(:from_db) do
          Person.where(:title => string)
        end

        it "does not convert the field to a bson id" do
          from_db.should == [ person ]
        end
      end
    end

    context "when providing string object ids" do

      context "when providing a single id" do

        let(:from_db) do
          Person.where(:_id => person.id.to_s).first
        end

        it "returns the matching documents" do
          from_db.should == person
        end
      end
    end

    context "chaining multiple wheres" do

      context "when chaining on the same key" do

        let(:from_db) do
          Person.where(:title => "Maam").where(:title => "Sir")
        end

        it "overrides the previous key" do
          from_db.should == [ person ]
        end
      end

      context "with different criteria on the same key" do

        it "merges criteria" do
          Person.where(:age.gt => 30).where(:age.lt => 40).should == [person]
        end

        it "typecasts criteria" do
          before_dob = (dob - 1.month).to_s
          after_dob = (dob + 1.month).to_s
          Person.where(:dob.gt => before_dob).and(:dob.lt => after_dob).should == [person]
        end

      end
    end

    context "with untyped criteria" do

      it "typecasts integers" do
        Person.where(:age => "33").should == [ person ]
      end

      it "typecasts datetimes" do
        Person.where(:lunch_time => lunch_time.to_s).should == [ person ]
      end

      it "typecasts dates" do
        Person.where({:dob => dob.to_s}).should == [ person ]
      end

      it "typecasts times with zones" do
        time = lunch_time.in_time_zone("Alaska")
        Person.where(:lunch_time => time).should == [ person ]
      end

      it "typecasts array elements" do
        Person.where(:age.in => [17, "33"]).should == [ person ]
      end

      it "typecasts size criterion to integer" do
        Person.where(:aliases.size => "2").should == [ person ]
      end

      it "typecasts exists criterion to boolean" do
        Person.where(:score.exists => "f").should == [ person ]
      end
    end

    context "with multiple complex criteria" do

      before do
        Person.create(:title => "Mrs", :age => 29)
        Person.create(:title => "Ms", :age => 41)
      end

      it "returns those matching both criteria" do
        Person.where(:age.gt => 30, :age.lt => 40).should == [person]
      end

      it "returns nothing if in and nin clauses cancel each other out" do
        Person.any_in(:title => ["Sir"]).not_in(:title => ["Sir"]).should == []
      end

      it "returns nothing if in and nin clauses cancel each other out ordered the other way" do
        Person.not_in(:title => ["Sir"]).any_in(:title => ["Sir"]).should == []
      end

      it "returns the intersection of in and nin clauses" do
        Person.any_in(:title => ["Sir", "Mrs"]).not_in(:title => ["Mrs"]).should == [person]
      end

      it "returns the intersection of two in clauses" do
        Person.where(:title.in => ["Sir", "Mrs"]).where(:title.in => ["Sir", "Ms"]).should == [person]
      end
    end

    context "with complex criterion" do

      context "#all" do

        it "returns those matching an all clause" do
          Person.where(:aliases.all => ["D", "Durran"]).should == [person]
        end
      end

      context "#exists" do

        it "returns those matching an exists clause" do
          Person.where(:title.exists => true).should == [person]
        end
      end

      context "#gt" do

        it "returns those matching a gt clause" do
          Person.where(:age.gt => 30).should == [person]
        end
      end

      context "#gte" do

        it "returns those matching a gte clause" do
          Person.where(:age.gte => 33).should == [person]
        end
      end

      context "#in" do

        it "returns those matching an in clause" do
          Person.where(:title.in => ["Sir", "Madam"]).should == [person]
        end

        it "allows nil" do
          Person.where(:ssn.in => [nil]).should == [person]
        end
      end

      context "#lt" do

        it "returns those matching a lt clause" do
          Person.where(:age.lt => 34).should == [person]
        end
      end

      context "#lte" do

        it "returns those matching a lte clause" do
          Person.where(:age.lte => 33).should == [person]
        end
      end

      context "#ne" do

        it "returns those matching a ne clause" do
          Person.where(:age.ne => 50).should == [person]
        end
      end

      context "#nin" do

        it "returns those matching a nin clause" do
          Person.where(:title.nin => ["Esquire", "Congressman"]).should == [person]
        end
      end

      context "#size" do

        it "returns those matching a size clause" do
          Person.where(:aliases.size => 2).should == [person]
        end
      end

      context "#match" do

        it "returns those matching a partial element in a list" do
          Person.where(:things.matches => { :phone => "HTC Incredible" }).should == [person]
        end
      end

    end

    context "Geo Spacial Complex Where" do

      let!(:home) do
        [-73.98,40.77]
      end

      describe "#near" do
        before do
          Bar.delete_all
          Bar.create_indexes
        end

        let!(:berlin) do
          Bar.create(:location => [ 52.30, 13.25 ])
        end

        let!(:prague) do
          Bar.create(:location => [ 50.5, 14.26 ])
        end

        let!(:paris) do
          Bar.create(:location => [ 48.48, 2.20 ])
        end

        it "returns the documents sorted closest to furthest" do
          Bar.where(:location.near => [ 41.23, 2.9 ]).should == [ paris, prague, berlin ]
        end

        it "returns the documents sorted closest to furthest" do
          Bar.where(:location.near => {:point=>[ 41.23, 2.9 ],:max => 20}).should == [ paris, prague, berlin ]
        end

        it "returns the documents sorted closest to furthest" do
          Bar.where(:location.near_sphere => [ 41.23, 2.9 ]).should == [ paris, prague, berlin ]
        end

      end

      context "#within" do

        context ":box, :polygon" do
          before do
            Bar.delete_all
            Bar.create_indexes
          end

          let!(:berlin) do
            Bar.create(:name => 'berlin', :location => [ 52.30, 13.25 ])
          end

          let!(:prague) do
            Bar.create(:name => 'prague',:location => [ 50.5, 14.26 ])
          end

          let!(:paris) do
            Bar.create(:name => 'prague',:location => [ 48.48, 2.20 ])
          end

          it "returns the documents within a box" do
            Bar.where(:location.within(:box) => [[ 47, 1 ],[ 49, 3 ]]).should == [ paris ]
          end

          it "returns the documents within a polygon", :if => (Mongoid.master.connection.server_version >= '1.9') do
            Bar.where(:location.within(:polygon) => [[ 47, 1 ],[49,1.5],[ 49, 3 ],[46,5]]).should == [ paris ]
          end

          it "returns the documents within a center" do
            Bar.where(:location.within(:center) => [[ 47, 1 ],4]).should == [ paris ]
          end

          it "returns the documents within a center_sphere" do
            Bar.where(:location.within(:center_sphere) => [[ 48, 2 ],0.1]).should == [ paris ]
          end

        end
        context ":circle :center_sphere" do
          before do
            Bar.delete_all
            Bar.create_indexes
          end
          let!(:mile1) do
            Bar.create(:name => 'mile1', :location => [-73.997345, 40.759382])
          end

          let!(:mile3) do 
            Bar.create(:name => 'mile2', :location => [-73.927088, 40.752151])            
          end

          let!(:mile7) do 
            Bar.create(:name => 'mile3', :location => [-74.0954913, 40.7161472])            
          end

          let!(:mile11) do 
            Bar.create(:name => 'mile4', :location => [-74.0604951, 40.9178011])            
          end

          it "returns the documents within a center_sphere" do
            Bar.where(:location.within(:center_sphere) => {:point => home,:max => 2, :unit => :mi}).should == [ mile1 ]
          end

          it "returns the documents within a center_sphere" do
            Bar.where(:location.within(:center_sphere) => {:point => home,:max => 4, :unit => :mi}).should include(mile3) 
          end

          it "returns the documents within a center_sphere" do
            Bar.where(:location.within(:center_sphere) => {:point => home,:max => 8, :unit => :mi}).should include(mile7) 
          end

          it "returns the documents within a center_sphere" do
            Bar.where(:location.within(:center_sphere) => {:point => home,:max => 12, :unit => :mi}).should include(mile11) 
          end
        end
      end
    end

  end

end
