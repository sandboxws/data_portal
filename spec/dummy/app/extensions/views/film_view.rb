module Views
  class FilmView
    include DataPortal::View

    model_class Film

    attribute :id, method_name: :film_id
    attribute :title
    attribute :description
    attribute :release_year

    count_field :categories
    count_field :actors

    field :categories, relation: :categories do
      attribute :id, method_name: :category_id
      attribute :name
    end

    field :actors, relation: :actors do
      attribute :id, method_name: :actor_id
      attribute :full_name do |obj|
        "#{obj.first_name} #{obj.last_name}"
      end
    end
  end
end
