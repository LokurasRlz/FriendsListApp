class Event < ApplicationRecord
  belongs_to :tool, optional: true

  validates :description, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
end
