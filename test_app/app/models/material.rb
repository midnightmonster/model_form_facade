class Material < ApplicationRecord
  belongs_to :workshop

  validates :name, presence: true
end
