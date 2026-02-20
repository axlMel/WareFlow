Rails.application.routes.draw do
  # Registro
  get  '/register', to: 'authentication/users#new',    as: :new_user
  post '/register', to: 'authentication/users#create', as: :users

  # Login
  get    '/login',  to: 'authentication/sessions#new',    as: :new_session
  post   '/login',  to: 'authentication/sessions#create', as: :sessions

  # Logout
  delete '/logout', to: 'authentication/sessions#destroy', as: :logout

  # Resto de rutas
  resources :favorites, only: [:index, :create, :destroy], param: :product_id
  resources :users, only: :show, path: "/user", param: :username
  resources :categories, except: :show
  resources :deliveries
  resources :assignments
  resources :supports
  resources :warranties do
    collection do
      get :import
      post :import
      get :download
      get :download_base
      get :export
      get :manual
      post :confirm_import
    end
  end
  resources :folios do
    collection do
      get :import
      get :download_base
      post :import
      get :export
      get :manual
      get :download
    end
  end
  resources :replacements, only: [:create]

  namespace :folios do
    get "api/:id/data",    to: "api#data"
    get "api/:id/summary", to: "api#summary"
    get "api/:id/products", to: "api#products"
    get "api/search",      to: "api#search"
  end

  resources :products, path: '/'do
    member do
      get :stock
    end
  end
  namespace :products do
    get ":id/installation_guide", to: "installation_guides#show", as: :installation_guide
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
