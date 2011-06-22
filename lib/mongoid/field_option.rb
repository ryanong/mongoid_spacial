# Field changes to Fields from mongoid 2.0 to mongoid 2.1
field = (defined?(Mongoid::Field)) ? Mongoid::Field : Mongoid::Fields

field.option :spacial do |model,field,options|
  options = {} unless options.kind_of?(Hash)
  model.class_eval do
    @@spacial_fields << field.name.to_sym if @@spacial_fields.kind_of? Array

    lat_meth = options[:lat] || "lat"
    lng_meth = options[:lng] || "lng"

    define_method "distance_from_#{field.name}" do |*args|
      self.distance_from(field.name, *args)
    end

    define_method field.name do
      output = read_attribute(field.name) || [nil,nil]
      output = (options[:return_array]) ? lng_lat_a : {lng_meth => output[0], lat_meth => output[0]}
      return options[:class].new(output) if options[:class]
      output
    end
    
    define_method "#{field.name}=" do |arg|
      if arg.kind_of?(Hash)
        arg = write_attribute([arg[lng_meth], arg[lat_meth]])
      elsif arg.respond_to?(:to_lng_lat)
        arg = write_attribute(arg.to_lat_lng) if arg.respond_to?(:to_lat_lng)
      else
        write_attribute(arg)
      end
      (options[:return_array]) ? arg[0..1] : {lng_meth => arg[0], lat_meth => arg[0]}
    end
  end
end
