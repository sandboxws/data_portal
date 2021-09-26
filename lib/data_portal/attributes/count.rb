module DataPortal::Attributes
  class Count < Standard
    # attr_accessor :default_value, :name, :method_name, :options

    # def initialize(name, options = {})
    #   @name = name
    #   @options = options
    #   @default_value = options[:default_value]
    #   @method_name = options[:method_name]
    # end

    def value(object)
      value = method_name.present? ? object.send(method_name) : object.send(name)
      value.nil? ? default_value : value.count
    end
  end
end
