class Book < ApplicationRecord
  validates :title, presence: true, length: { minimum: 2 }
  validates :author, presence: true
  validates :genre, inclusion: { in: ['Fiction', 'Non-Fiction', 'Mystery', 'Romance'] }
  validates :format, inclusion: { in: ['hardcover', 'paperback'] }, allow_blank: true
end
