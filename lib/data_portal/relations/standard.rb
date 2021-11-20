module DataPortal::Relations
  class Standard
    TYPES = %i[has_one belongs_to has_many]
    TYPES.each do |type|
      define_method "#{type}?" do
        self.type == type
      end
    end

    attr_accessor :default_value,
                  :name,
                  :method_name,
                  :options,
                  :type,
                  :attributes,
                  :relations,
                  :order,
                  :count_attributes

    def initialize(name, options = {}, &block)
      @name = name
      @options = options
      @attributes = {}
      @relations = {}
      @count_attributes = {}
      @type = options[:type] || :has_one
      @default_value = options[:default_value]
      @method_name = options[:method_name]
      @order = options[:order]

      process_block(&block) if block_given?
    end

    def process_block(&block)
      instance_eval(&block)
    end

    def attribute(name, options = {}, &block)
      puts "Adding attribute(#{name}) for #{self.name}"
      attributes[name] = DataPortal::Attributes::Standard.new(name, options, &block)
    end

    def relation(name, options = {}, &block)
      puts "Nested relation: #{name}"
      relations[name] = DataPortal::Relations::Standard.new(name, options, &block)
    end

    def has_one(name, options = {}, &block)
      relation(name, options, &block)
    end

    def count_attribute(name, _options = {})
      count_attributes[name] = DataPortal::Attributes::Count.new(name)
    end

    def value(object)
      value = method_name.present? ? object.send(method_name) : object.send(name)
      return unless value.present?
      return object_value(value) unless value.is_a?(ActiveRecord::Associations::CollectionProxy)

      value.map do |obj|
        object_value obj
      end
    end

    private

    # TODO: add recursive support
    # TODO: Refactor to rendering utils
    def object_value(value)
      output = {}
      if value.present?
        # Render attributes
        if attributes.size.positive?
          output = render_attributes output, value, attributes

          count_attributes.each do |name, attr|
            Concurrent::Future.execute do
              output["#{name}_count"] = attr.value value
            end
          end
        end

        # Render nested relations
        # N+1 - Should be fixed using either default providers or custom
        # Warn if neither are available
        relations.each do |name, relation|
          # output[name] = relation.value value
          output[name] = {}
          Concurrent::Future.execute do
            relations_value(output[name], name, relation, value.send(name))
          end
        end
      end

      output || default_value
    end

    def relations_value(output, _name, root, value)
      # render_attributes output, value, attributes if root.relations.size.zero?
      render_attributes output, value, root.attributes if root.relations.size.zero?
    end

    def render_attributes(output, value, attributes)
      attributes.each do |name, attr|
        Concurrent::Future.execute do
          output[name] = attr.value value
        end
      end

      output
    end
  end
end
