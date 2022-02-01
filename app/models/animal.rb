# frozen_string_literal: true

class Animal < ApplicationRecord
  has_many :sightings
  accepts_nested_attributes_for :sightings
  validates :common_name, :latin_name, presence: true
  validate :latin_name_not_the_same_as_common_name
  validates :common_name, :latin_name, uniqueness: true
  validates_associated :sightings

  private

  def latin_name_not_the_same_as_common_name
    errors.add(:latin_name, 'cannot be the same as common name') if latin_name == common_name
  end
end
