class Book < ApplicationRecord
  belongs_to :author

  validates :title, presence: true, uniqueness: { scope: :author }
end
