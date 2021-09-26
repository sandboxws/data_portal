module Providers
  class FooProvider
    include DataPortal::Provider

    def execute
      OpenStruct.new(
        foo: "Foo - Time was: #{filters[:start_date]}",
        bar: "Bar - film_id: #{filters[:film_id]}"
      )
    end
  end
end
