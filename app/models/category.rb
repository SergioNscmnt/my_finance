class Category < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :restrict_with_exception
  has_many :category_budgets, dependent: :destroy

  enum kind: { income: 0, expense: 1 }

  validates :name, presence: true
  validates :kind, presence: true
  validates :name, uniqueness: { scope: :user_id }
end
