# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sighting, type: :model do
  it 'is valid with valid attributes' do
    animal =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    sighting =
      animal.sightings.create latitude: '45.5152',
                              longitude: '122.6784',
                              date: '2022-01-12 16:57'
    expect(sighting).to be_valid
  end
  it 'is not valid without a latitude' do
    animal =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    sighting =
      animal.sightings.create longitude: '122.6784', date: '2022-01-12 16:57'
    expect(sighting.errors[:latitude]).to_not be_empty
  end
  it 'is not valid without a longitude' do
    animal =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    sighting =
      animal.sightings.create latitude: '45.5152', date: '2022-01-12 16:57'
    expect(sighting.errors[:longitude]).to_not be_empty
  end
  it 'is not valid without a date' do
    animal =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    sighting =
      animal.sightings.create latitude: '45.5152', longitude: '122.6784'
    expect(sighting.errors[:date]).to_not be_empty
  end
end
