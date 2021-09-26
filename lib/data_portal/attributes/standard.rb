module DataPortal::Attributes
  class Standard
    attr_accessor :default_value,
                  :name,
                  :method_name,
                  :options,
                  :given_block,
                  :type

    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      @method_name = options[:method_name]
      @default_value = options[:default_value]
      @given_block = block
      @type = self.class.name.demodulize.underscore.to_sym
    end

    def value(object)
      value = if given_block.present?
                given_block.call(object)
              else
                method_name.present? ? object.send(method_name) : object[name]
              end
      value = default_value if value.nil? && default_value.present?

      value
    end
  end
end
