class Array
  def to_lng_lat
    self[0..1].map(&:to_f)
  end
end  

class Hash
  def to_lng_lat
    raise "Hash must have at least 2 items" if self.size < 2
    [to_lng, to_lat]
  end

  def to_lat
    v = (Mongoid::Spacial::LAT_SYMBOLS & self.keys).first
    return self[v.first] if !v.nil? && self[v.first]
    raise "Hash must contain #{Mongoid::Spacial::LAT_SYMBOLS.inspect} if ruby version is less than 1.9" if RUBY_VERSION.to_f < 1.9
    raise "Hash cannot contain #{Mongoid::Spacial::LNG_SYMBOLS.inspect} as the second item if there is no #{Mongoid::Spacial::LAT_SYMBOLS.inspect}" if Mongoid::Geo.lng_symbols.index(self.keys[1])    
    self.values[1]
  end

  def to_lng
    v = (Mongoid::Spacial::LNG_SYMBOLS & self.keys).first
    return self[v.first] if !v.nil? && self[v.first]
    raise "Hash cannot contain #{Mongoid::Spacial::LAT_SYMBOLS.inspect} as the first item if there is no #{Mongoid::Spacial::LNG_SYMBOLS.inspect}" if Mongoid::Geo.lat_symbols.index(self.keys[0])
    self.values[0]
  end
end 
