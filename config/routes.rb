Rails.application.routes.draw do
  root "folders#index"

  resources :folders do
     member do
    post 'combine_documents'
  end
    resources :documents
  end
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is lives  # Defines the root path route ("/")
  # root "posts#index"
end
