module DataPortal::Attributes
  class Standard
    TYPES = %i[standard count standalone]
    TYPES.each do |type|
      define_method "#{type}?" do
        self.type == type
      end
    end

    attr_accessor :default_value,
                  :name,
                  :method_name,
                  :options,
                  :given_block,
                  :type,
                  :as

    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      @method_name = options[:method_name]
      @default_value = options[:default_value]
      @given_block = block
      @type = options[:type] || :standard
      @as = options[:as]
    end

    def value(object)
      value = if given_block.present?
                given_block.call(object)
              else
                value = standard_value object
                value = send("#{type}_value", value) unless type == :standard
                value
              end
      value = default_value if value.nil? && default_value.present?

      value
    end

    def display_name
      case type
      when :standard
        as.present? ? as : name
      when :count
        as.present? ? as : "#{name}_count"
      end
    end

    def standard_display_name
      as
    end

    def count_display_name
      "#{name}_count"
    end

    def standard_value(object)
      #   method_name.present? ? object.send(method_name) : object[name]
      method_name.present? ? object.send(method_name) : object.send(name)
    end

    def count_value(value)
      value.nil? ? default_value : value.count
    end
  end
end
