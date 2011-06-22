class Bar
  include Mongoid::Document
  include Mongoid::Spacial::Document
  
  field :name, :type => String
  field :location, :type => Array, :spacial => true
  references_one :rating, :as => :ratable
  spacial_index :location
end
