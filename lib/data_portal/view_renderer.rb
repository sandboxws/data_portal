module DataPortal
  class ViewRenderer
    attr_accessor :view, :source, :output

    def initialize(view, source)
      @view = view
      @source = source
      @output = {}
    end

    def self.render(view, source)
      new(view, source).render
    end

    def render
      source.is_a?(Array) ? render_many : render_one
    end

    def render_many; end

    def render_one
      render_attributes output

      view.relations.each do |name, relation|
        output[name] = relation.has_many? ? [] : {}
        render_relations output[name], name, relation, source
      end

      render_count_attributes output
      # render_standalone_attributes output

      output
    end

    def render_relations(output, name, relation, source)
      # if relation.relations.size.zero?
      if relation.has_many?
        output << relation.value(source)
      else
        source = source.send name
        if !source.is_a?(ActiveRecord::Associations::CollectionProxy)
          # Probably redundant
        else
          source.each_with_index do |src, idx|
            output[idx] = {}
            relation.relations.each do |a_name, rel|
              output[idx][a_name] = rel.has_many? ? [] : {}
              render_relations output[idx][a_name], a_name, rel, src
            end
          end
        end
      end
    end

    def render_attributes(output)
      view.attributes.each do |name, attr|
        next unless attr.standard?

        # TODO: Handle options & default value
        output[name] = attr.value source
      end
    end

    def render_count_attributes(output)
      view.count_attributes.each do |_name, attr|
        # TODO: Add "as:" option support
        output[attr.display_name] = attr.value source
      end
    end

    def render_standalone_attributes(output)
      view.attributes.each do |name, attr|
        next unless attr.type == :standalone

        output[name] = attr.value
      end
    end
  end
end
