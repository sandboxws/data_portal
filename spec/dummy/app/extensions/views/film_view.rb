module Views
  class FilmView
    include DataPortal::View

    model_class Film

    attribute :id, method_name: :film_id
    attribute :title
    attribute :description
    attribute :release_year

    attribute :actors, type: :count
    attribute :categories, type: :count

    has_one :language do
      attribute :name
    end

    has_many :categories do
      attribute :id, method_name: :category_id
      attribute :name
      count_attribute :films
    end

    has_many :actors, order: { last_name: :asc } do
      attribute :id, method_name: :actor_id
      attribute :full_name do |obj|
        "#{obj.first_name} #{obj.last_name}"
      end
    end

    has_many :inventories do
      attribute :inventory_id
      attribute :last_update

      has_one :store do
        attribute :store_id
        attribute :manager_staff_id
        attribute :address_id
      end
    end

    # attribute :foobar, provider: Providers::FooProvider do
    #   argument :start_date, value: Time.now
    #   argument :film_id
    #   attribute :foo
    #   attribute :bar
    # end
  end
end
