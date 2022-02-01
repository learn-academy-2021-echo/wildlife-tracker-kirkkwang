# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Animal, type: :model do
  it 'is valid with valid attributes' do
    animal =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    expect(animal).to be_valid
  end
  it 'must have a common name' do
    animal = Animal.create latin_name: 'Mustela nivalis', kingdom: 'mammal'
    expect(animal.errors[:common_name]).to_not be_empty
  end
  it 'must have a latin name' do
    animal = Animal.create common_name: 'Weasel', kingdom: 'mammal'
    expect(animal.errors[:latin_name]).to_not be_empty
  end
  it 'cannot have the latin name be the same as the common name' do
    animal =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Weasel',
                    kingdom: 'mammal'
    expect(animal.errors[:latin_name]).to_not be_empty
  end
  it 'must have a unique common name' do
    animal1 =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    animal2 =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela erminea',
                    kingdom: 'mammal'
    expect(animal2.errors[:common_name]).to_not be_empty
  end
  it 'must have a unique latin name' do
    animal1 =
      Animal.create common_name: 'Weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    animal2 =
      Animal.create common_name: 'Short-tailed weasel',
                    latin_name: 'Mustela nivalis',
                    kingdom: 'mammal'
    expect(animal2.errors[:latin_name]).to_not be_empty
  end
end
