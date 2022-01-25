Rails.application.routes.draw do
  resources :sightings
  resources :animals
  resources :animals do
    resources :sightings
  end
end
