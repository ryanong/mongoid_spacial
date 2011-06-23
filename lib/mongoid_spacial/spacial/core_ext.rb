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
    v = (Mongoid::Spacial.lat_symbols & self.keys).first
    return self[v] if !v.nil? && self[v]
    raise "Hash must contain #{Mongoid::Spacial.lat_symbols.inspect} if ruby version is less than 1.9" if RUBY_VERSION.to_f < 1.9
    raise "Hash cannot contain #{Mongoid::Spacial.lng_symbols.inspect} as the second item if there is no #{Mongoid::Spacial.lat_symbols.inspect}" if Mongoid::Spacial.lng_symbols.index(self.keys[1])    
    self.values[1]
  end

  def to_lng
    v = (Mongoid::Spacial.lng_symbols & self.keys).first
    return self[v] if !v.nil? && self[v]
    raise "Hash cannot contain #{Mongoid::Spacial.lat_symbols.inspect} as the first item if there is no #{Mongoid::Spacial.lng_symbols.inspect}" if Mongoid::Spacial.lat_symbols.index(self.keys[0])
    self.values[0]
  end
end 
