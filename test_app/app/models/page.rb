class Page < ApplicationRecord
  belongs_to :rich_content, class_name: "RichContent", optional: true

  accepts_nested_attributes_for :rich_content

  validates :name, presence: true
end
