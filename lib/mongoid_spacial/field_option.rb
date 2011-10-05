require 'ostruct'
# Field changes to Fields from mongoid 2.0 to mongoid 2.1
field = (defined?(Mongoid::Field)) ? Mongoid::Field : Mongoid::Fields

field.option :spacial do |model,field,options|
  options = {} unless options.kind_of?(Hash)
  lat_meth = options[:lat] || :lat
  lng_meth = options[:lng] || :lng
  model.class_eval do
    self.spacial_fields ||= []
    self.spacial_fields << field.name.to_sym if self.spacial_fields.kind_of? Array

    define_method "distance_from_#{field.name}" do |*args|
      self.distance_from(field.name, *args)
    end

    define_method field.name do
      output = self[field.name] || [nil,nil]
      output = {lng_meth => output[0], lat_meth => output[1]} unless options[:return_array]
      return options[:class].new(output) if options[:class]
      output
    end

    define_method "#{field.name}=" do |arg|
      if arg.kind_of?(Hash) && arg[lng_meth] && arg[lat_meth]
        arg = [arg[lng_meth].to_f, arg[lat_meth].to_f]
      elsif arg.respond_to?(:to_lng_lat)
        arg = arg.to_lng_lat
      end
      self[field.name]=arg
      arg = [nil,nil] if arg.nil?
      return arg[0..1] if options[:return_array]
      h = {lng_meth => arg[0], lat_meth => arg[1]}
      return h if options[:class].blank?
      options[:class].new(h)
    end
  end
end
