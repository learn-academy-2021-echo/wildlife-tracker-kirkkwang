class AddForeignKeyToAnimal < ActiveRecord::Migration[6.1]
  def change
    add_column :sightings, :animal_id, :integer
  end
end
