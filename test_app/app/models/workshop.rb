class Workshop < ApplicationRecord
  belongs_to :description, class_name: "RichContent", optional: true
  belongs_to :pricing_info, class_name: "RichContent", optional: true
  has_many :materials, dependent: :destroy
  has_many :registrations, dependent: :destroy

  accepts_nested_attributes_for :description, :pricing_info
  accepts_nested_attributes_for :materials, allow_destroy: true

  validates :title, :slug, :category, presence: true
  validates :slug, uniqueness: true, format: {with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens"}

  scope :published, -> { where(status: "published") }

  def category_options
    [["Cooking", "cooking"], ["Art", "art"], ["Music", "music"], ["Fitness", "fitness"]]
  end
end
