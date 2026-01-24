class Transaction < ApplicationRecord
  belongs_to :category
  belongs_to :user

  enum kind: { income: 0, expense: 1 }

  validates :title, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :kind, presence: true
  validates :occurred_on, presence: true
end
