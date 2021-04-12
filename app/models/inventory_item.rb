class InventoryItem < ApplicationRecord
  belongs_to :user
  belongs_to :book

  validates :read_status, inclusion: { in: %w[read to-read currently-reading] }
  validates :format, inclusion: { in: %w[paperback hardback ebook] }
end
