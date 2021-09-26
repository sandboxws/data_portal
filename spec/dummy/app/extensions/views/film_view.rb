module Views
  class FilmView
    include DataPortal::View

    model_class Film

    attribute :id, method_name: :film_id
    attribute :title
    attribute :description
    attribute :release_year

    count_attribute :categories
    count_attribute :actors
    # attribute :actors, type: :count
    # attribute :actors, count: true

    relation :categories do
      attribute :id, method_name: :category_id
      attribute :name
      count_attribute :films
    end

    relation :actors, order: { last_name: :asc } do
      attribute :id, method_name: :actor_id
      attribute :full_name do |obj|
        "#{obj.first_name} #{obj.last_name}"
      end
    end

    attribute :foobar, provider: Providers::FooProvider do
      argument :start_date, value: Time.now
      argument :film_id
      attribute :foo
      attribute :bar
    end
  end
end
