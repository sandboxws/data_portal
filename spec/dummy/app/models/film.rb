class Film < ApplicationRecord
  self.table_name = 'film'
  self.primary_key = 'film_id'

  has_many :film_actors
  has_many :actors, through: :film_actors

  has_many :film_categories
  has_many :categories, through: :film_categories

  has_many :inventories
  belongs_to :language
end
