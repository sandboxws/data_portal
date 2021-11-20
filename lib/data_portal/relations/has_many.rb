module DataPortal::Relations
  class HasMany
    include DataPortal::Relations::Base

    attr_accessor :has_many_relations

    def initialize(name, options = {}, &block)
      super
      @has_many_relations = {}
    end

    def has_many(name, options = {}, &block); end
  end
end
