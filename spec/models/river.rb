class River
  include Mongoid::Document
  include Mongoid::Spacial::Document

  field :name,              type: String
  field :length,            type: Integer
  field :average_discharge, type: Integer
  field :source,            type: Array,    spacial: true
  # set return_array to true if you do not want a hash returned all the time
  field :mouth,             type: Array,    spacial: {lat: 'latitude', lng: 'longitude'}
  field :mouth_array,       type: Array,    spacial: {return_array: true}

  # simplified spacial indexing
  # you can only index one field in mongodb < 1.9
  spacial_index :source
  # alternatives
  # index [[ :spacial, Mongo::GEO2D ]], {min:-400, max:400}
  # index [[ :spacial, Mongo::GEO2D ]], {bit:32}
  # index [[ :spacial, Mongo::GEO2D ],:name]
end
