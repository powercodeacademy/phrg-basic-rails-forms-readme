Rails.application.routes.draw do
  # RESTful routes for form examples
  resources :books, only: [:new, :create, :edit, :update]

  # Alternative custom routes (commented out for reference)
  # get '/newbook', to: 'books#new'
  # post '/book', to: 'books#create'
end
