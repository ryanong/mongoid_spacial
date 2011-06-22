Mongoid Spacial
============

A Mongoid Extention that simplifies and adds support for MongoDB Geo Spacial Calculations.

Quick Start
-----------
Add mongoid_spacial to your Gemfile:

```ruby
gem 'mongoid_spacial'
```

Set up some slugs:

```ruby
class River
  include Mongoid::Document
  include Mongoid::Geo::Document

  field :name,              type: String
  field :length,            type: Integer
  field :average_discharge, type: Integer
  field :source,            type: Array,    spacial: true
  # if you want something besides the defaults {bit: 24, min: -180, max: 180} just set index to the options on the index
  # field :source,            type: Array,    spacial: true
  # try not set index for this field manually as we record what geo fields are index for some handy fields later

  # set return_array to true if you do not want a hash returned all the time
  field :mouth,             type: Array,    spacial: {lat: 'latitude', lng: 'longitude', return_array: true }

  # simplified spacial indexing
  # you can only index one
  spacial_index :source
  # alternative 
end
```

Before we manipulate the data mongoid_spacial handles is what we call points.
Points can be:
* an unordered hash with the lat long string keys defined when setting the field (only applies for setting the field)
* longitude latitude array in that order - [long,lat]
* an unordered hash with latitude key(:lat, :latitude) and a longitude key(:lon, :long, :lng, :longitude)
* an ordered hash with longitude as the first item and latitude as the second item
  This hash does not have include the latitude and longitude keys
  \*only works in ruby 1.9 and up because hashes below ruby 1.9 because they are not ordered
* anything with the method to_lng_lat that converts it to a [long,lat]
We store data in the DB as a [lng,lat] array then reformat when it is returned to you

```ruby
hudson = River.create(
  name: 'Hudson',
  length: 315,
  average_discharge: 21_400,
  # when setting array LONGITUDE MUST BE FIRST LATITUDE MUST BE SECOND
  # source: [-73.935833,44.106667],
  # but we can use hash in any order,
  # the default keys for latitude and longitude are 'lat' and 'lng' respectively
  source: {'lat' => 44.106667, 'lng' => -73.935833},
  # remember keys must be strings
  mouth: {'latitude' => 40.703056, 'longitude' => -74.026667}
)

# now to access this spacial information we can now do this
hudson.source #=> {'lng' => -73.935833, 'lat' => 44.106667}
hudson.mouth  #=> [-74.026667, 40.703056] # notice how this returned as a lng,lat array because return_array was true
# notice how the order of lng and lat were switched. it will always come out like this when using spacial.
```
Mongoid Geo has extended all built in spacial symbol extentions
* near
    River.where(:source.near => [-73.98, 40.77])
    River.where(:source.near => [[-73.98, 40.77],5]) # sets max distance of 5
    River.where(:source.near => {:point => [-73.98, 40.77], :max => 5}) # sets max distance of 5
    River.where(:source.near(:sphere) => [[-73.98, 40.77],5]) # sets max distance of 5 radians
    River.where(:source.near(:sphere) => {:point => [-73.98, 40.77], :max => 5, :unit => :km}) # sets max distance of 5 km    
    River.where(:source.near(:sphere) => [-73.98, 40.77])
* within
    River.where(:source.within(:box) => [[-73.99756,40.73083], [-73.988135,40.741404]])
    River.where(:source.within(:box) => [ {:lat => 40.73083, :lng => -73.99756}, [-73.988135,40.741404]])
    River.where(:source.within(:polygon) => [ [ 10, 20 ], [ 10, 40 ], [ 30, 40 ], [ 30, 20 ] ]
    River.where(:source.within(:polygon) => { a : { x : 10, y : 20 }, b : { x : 15, y : 25 }, c : { x : 20, y : 20 } })
    River.where(:source.within(:center) => [[-73.98, 40.77],5])         # same format as near
    River.where(:source.within(:center_sphere) => [[-73.98, 40.77],5])  # same format as near(:sphere)

One of the most handy features we have added is geo_near finder

```ruby
# accepts all criteria chains except without, only, asc, desc, order\_by
# pagination does not work yet but will be added in the next version
River.where(:name=>'hudson').geo_near({:lat => 40.73083, :lng => -73.99756})

# geo\_near accepts a few parameters besides a point
# :num = limit
# :query = where
# :unit - [:km, :m, :mi, :ft] - converts :max\_distance to appropriate values and automatically sets :distance\_multiplier. accepts 
# :max\_distance - Integer
# :distance\_multiplier - Integer
# :spherical - true - To enable spherical calculations
River.geo_near([-73.99756,40.73083], :max_distance => 4, :unit => :mi, :spherical)

```

ToDo
-----------
 1. Add pagination 

Thanks
-----------
* Thanks to Kristian Mandrup for creating the base of the gem
* Thanks to CarZen LLC. for letting me release the code we are using

Contributing to mongoid_ranges
-----------
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

Copyright
-----------
Copyright (c) 2011 Ryan Ong. See LICENSE.txt for
further details.

