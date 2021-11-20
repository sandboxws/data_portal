class Inventory < ApplicationRecord
  self.table_name = 'inventory'
  self.primary_key = 'inventory_id'

  belongs_to :store
end
