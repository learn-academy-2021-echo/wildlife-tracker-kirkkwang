# Wildlife Tracker Challenge

### Additional Resources

- [Controller Specs](https://relishapp.com/rspec/rspec-rails/docs/controller-specs)
- [Model Specs](https://relishapp.com/rspec/rspec-rails/docs/model-specs)
- [Handling Errors in an API Application the Rails Way](https://blog.rebased.pl/2016/11/07/api-error-handling.html)

### Set Up

#### Creating a new Rails app:

```
$ rails new wildlife_tracker -d postgresql -T
$ cd wildlife_tracker
$ rails db:create
$ bundle add rspec-rails
$ rails generate rspec:install
$ rails server
```

### Troubleshooting Tips

- Did you create your database?
- Did you migrate?
- Is your server running?
- Are you requesting the correct route?
- Errors? Always look at the first error in the list.

## The API Stories

The Forest Service is considering a proposal to place in conservancy a forest of virgin Douglas fir just outside of Portland, Oregon. Before they give the go-ahead, they need to do an environmental impact study. They've asked you to build an API the rangers can use to report wildlife sightings.

- **Story**: As a developer I can create an animal model in the database. An animal has the following information: common name, latin name, kingdom (mammal, insect, etc.).

```Shell
$ rails g resource Animal common_name:string latin_name:string kingdom:string
```

- **Story**: As the consumer of the API I can see all the animals in the database.
  - _Hint_: Make a few animals using Rails Console

```Shell
$ Animal.create common_name:'Weasel', latin_name:'Mustela nivalis', kingdom:'mammal'
$ Animal.create common_name:'Painted turtle', latin_name:'Chrysemys picta', kingdom:'reptile'
$ Animal.create common_name:'Western meadowlark', latin_name:'Sturnella neglecta', kingdom:'bird'
```

```Ruby
def index
  animal = Animal.all
  render json: animal
end
```

- **Story**: As the consumer of the API I can update an animal in the database.

```Ruby
class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
end
```

```Ruby
def update
  animal = Animal.find(params[:id])
  animal.update(animal_params)
  if animal.valid?
    render json: animal
  else
    render json: animal.errors
  end
end

private

def animal_params
  params.require(:animal).permit(:common_name, :latin_name, :kingdom)
end
```

```JSON
{
	"common_name": "weasel",
	"latin_name": "Mustela nivalis",
  "kingdom": "mammal"
}
```

- **Story**: As the consumer of the API I can destroy an animal in the database.

```Ruby
def destroy
  animal = Animal.find(params[:id])
  if animal.destroy
    render json: animal
  else
    render json: animal.errors
  end
end
```

- **Story**: As the consumer of the API I can create a new animal in the database.

```Ruby
def create
  animal = Animal.create(animal_params)
  if animal.valid?
    render json: animal
  else
    render json: animal.errors
  end
end
```

```JSON
{
	"common_name": "elk",
	"latin_name": "Cervus canadensis",
  "kingdom": "mammal"
}
```

- **Story**: As the consumer of the API I can create a sighting of an animal with date (use the _datetime_ datatype), a latitude, and a longitude.
- _Hint_: An animal has_many sightings. (rails g resource Sighting animal_id:integer ...)

```Shell
$ rails g resource Sighting date:datetime latitude:decimal longitude:decimal
$ rails db:migrate
# forgot to put foreign key
$ rails generate migration add_foreign_key_to_animal
# though now I realize it's actually to Sighting
$ rails db:migrate
```

```Ruby
  resources :animals do
    resources :sightings
  end
```

```Ruby
class Animal < ApplicationRecord
  has_many :sightings
end
```

```Ruby
class Sighting < ApplicationRecord
  belongs_to :animal
end
```

```Ruby
def create
  sighting = Animal.find(params[:animal_id]).sightings.create(sighting_params)
  if sighting.valid?
    render json: sighting
  else
    render json: sighting.errors
  end
end
```

- **Story**: As the consumer of the API I can update an animal sighting in the database.

```Ruby
class SightingsController < ApplicationController
  def update
    sighting = Animal.find(params[:animal_id]).sightings.find(params[:id])
    sighting.update(sighting_params)
    if sighting.valid?
      render json: sighting
    else
      render json: sighting.errors
    end
  end

  private

  def sighting_params
    params.require(:sighting).permit(:date, :latitude, :longitude)
  end
end
```

```JSON
{
  "date":"2022-01-18 14:43:00",
  "latitude":"45.5152",
  "longitude":"122.6784"
}
```

- **Story**: As the consumer of the API I can destroy an animal sighting in the database.

```Ruby
def destroy
  sighting = Animal.find(params[:animal_id]).sightings.find(params[:id])
  sighting.destroy
  if sighting.destroy
    render json: sighting
  else
    render json: sighting.errors
  end
end
```

- **Story**: As the consumer of the API, when I view a specific animal, I can also see a list sightings of that animal.

  - _Hint_: Checkout the [ Ruby on Rails API docs ](https://api.rubyonrails.org/classes/ActiveModel/Serializers/JSON.html#method-i-as_json) on how to include associations.

```Ruby
def show
  animal = Animal.find(params[:id]).as_json(include: :sightings)
  render json: animal
end
```

```JSON
# result
{
    "id": 2,
    "common_name": "Painted turtle",
    "latin_name": "Chrysemys picta",
    "kingdom": "reptile",
    "created_at": "2022-01-21T23:26:53.070Z",
    "updated_at": "2022-01-21T23:26:53.070Z",
    "sightings": [
        {
            "id": 3,
            "date": "2022-01-12T16:57:00.000Z",
            "latitude": "45.5152",
            "longitude": "122.6784",
            "created_at": "2022-01-22T01:06:08.630Z",
            "updated_at": "2022-01-22T01:06:28.104Z",
            "animal_id": 2
        }
    ]
}
```

- **Story**: As the consumer of the API, I can run a report to list all sightings during a given time period.
  - _Hint_: Your controller can look like this:

```ruby
class SightingsController < ApplicationController
  def index
    sightings = Sighting.where(date: params[:start_date]..params[:end_date])
    render json: sightings
  end
end
```

`localhost:3000/sightings?start_date="2022-01-16 00:00"&end_date="2022-01-17 23:59"`

Remember to add the start_date and end_date to what is permitted in your strong parameters method.

## Stretch Challenges

**Note**: All of these stories should include the proper RSpec tests. Validations will require specs in `spec/models`, and the controller method will require specs in `spec/requests`.

- **Story**: As the consumer of the API, I want to see validation errors if a sighting doesn't include: latitude, longitude, or a date.

```Ruby
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
```

- **Story**: As the consumer of the API, I want to see validation errors if an animal doesn't include a common name, or a latin name.

```Ruby
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
end
```

- **Story**: As the consumer of the API, I want to see a validation error if the animals latin name matches exactly the common name.

```Ruby
validate :latin_name_not_the_same_as_common_name

private

def latin_name_not_the_same_as_common_name
  if latin_name == common_name
    errors.add(:latin_name, 'cannot be the same as common name')
  end
end
```

```Ruby
it 'cannot have the latin name be the same as the common name' do
  animal =
    Animal.create common_name: 'Weasel',
                  latin_name: 'Weasel',
                  kingdom: 'mammal'
  expect(animal.errors[:latin_name]).to_not be_empty
end
```

- **Story**: As the consumer of the API, I want to see a validation error if the animals latin name or common name are not unique.

```Ruby
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
```

```Ruby
validates :common_name, :latin_name, uniqueness: true
```

- **Story**: As the consumer, I want to see a status code of 422 when a post request can not be completed because of validation errors.
  - Check out [Handling Errors in an API Application the Rails Way](https://blog.rebased.pl/2016/11/07/api-error-handling.html)

```Ruby
# animals_controller.rb
# added status: :unprocessable_entity
def create
  animal = Animal.create(animal_params)
  if animal.valid?
    render json: animal
  else
    render json: animal.errors, status: :unprocessable_entity
  end
end
```

```Ruby
# sightings_controller.rb
def create
  sighting = Animal.find(params[:animal_id]).sightings.create(sighting_params)
  if sighting.valid?
    render json: sighting
  else
    render json: sighting.errors, status: :unprocessable_entity
  end
end
```

## Super Stretch Challenge

- **Story**: As the consumer of the API, I can submit sighting data along with a new animal in a single API call.
  - _Hint_: Look into `accepts_nested_attributes_for`

```Ruby
# added sightings_attribute: [:date, :latitude, :longitude]
def animal_params
  params
    .require(:animal)
    .permit(
      :common_name,
      :latin_name,
      :kingdom,
      sightings_attributes: %i[date latitude longitude],
    )
end
```

```JSON
 {
  "common_name": "North American beaver",
  "latin_name": "Castor canadensis",
  "kingdom": "mammal",
  "sightings_attributes": [
    {
      "date": "2022-01-24T08:18:00.000Z",
      "latitude": "45.5152",
      "longitude": "122.6784"
    }
  ]
}
```
