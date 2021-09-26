class Actor < ApplicationRecord
  self.table_name = 'actor'
  self.primary_key = 'actor_id'

  has_many :film_actors
  has_many :films, through: :film_actors
end
