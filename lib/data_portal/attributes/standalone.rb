module DataPortal::Attributes
  class Standalone < Standard
    attr_accessor :provider_class, :provider, :given_block, :arguments, :attributes, :source, :data

    def initialize(name, options = {}, &block)
      super
      @provider_class = options[:provider]
      @given_block = block
      @arguments = {}
      @attributes = {}
    end

    def prepare(source)
      @source = source
      instance_eval(&given_block)
      filters = arguments.map { |name, options| [name, options[:value]] }.to_h
      @provider = provider_class.new(ids: nil, attributes: attributes, model_class: nil, filters: filters,
                                     options: options)
      @data = @provider.execute
    end

    def value
      # value = method_name.present? ? object.send(method_name) : object.send(name)
      output = {}
      attributes.each do |name, attr|
        output[name] = attr.value data
      end
      output
    end

    def argument(name, options = {})
      # arguments[name] = name.is_a?(Hash) ? name.values.first : name
      options[:value] = source.send(name) if !options[:value].present? && source.respond_to?(name)
      arguments[name] = options
    end

    def attribute(name, options = {}, &block)
      attributes[name] = DataPortal::Attributes::Standard.new(name, options, &block)
    end
  end
end
