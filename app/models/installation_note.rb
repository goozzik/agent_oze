class InstallationNote < ApplicationRecord
  belongs_to :lead
  has_one_attached :file

  validates :content, presence: true
end
