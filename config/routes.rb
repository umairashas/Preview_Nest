Rails.application.routes.draw do
  root "folders#index"

  resources :folders do
     member do
    post 'combine_documents'
  end
    resources :documents
  end


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is lives  # Defines the root path route ("/")
  # root "posts#index"
end
