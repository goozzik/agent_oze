Rails.application.routes.draw do
  namespace :admin do
    resources :jobs, only: [:index, :show]
  end
  get "measurements/new"
  get "measurements/create"
  get "measurements/show"
  get "measurements/edit"
  get "measurements/update"
  get "measurements/destroy"
  get "boiler_calculations/new"
  get "boiler_calculations/create"
  get "boiler_calculations/show"
  get "boiler_calculations/edit"
  get "boiler_calculations/update"
  get "boiler_calculations/destroy"
  get "offers/index"
  get "offers/show"
  get "offers/new"
  get "offers/create"
  get "offers/edit"
  get "offers/update"
  get "offers/destroy"
  get "offers/send_offer"
  get "offers/download_pdf"
  get "meetings/new"
  get "meetings/create"
  get "meetings/show"
  get "meetings/edit"
  get "meetings/update"
  get "meetings/destroy"
  devise_for :users
  
  root "leads#index"

  resources :leads do
    member do
      patch :update_status
    end
    
    resources :meetings, except: [:index]
    resources :measurements, except: [:index]
    resources :boiler_calculations, except: [:index]
    resources :installation_notes, except: [:index]
    resources :offers do
      member do
        post :send_offer
        get :download_pdf
      end
      resources :offer_items, except: [:index, :show]
    end
    resources :contracts, except: [:index, :edit, :update] do
      member do
        post :send_contract
        get :download_pdf
      end
    end
    resources :commissions, except: [:index, :edit, :update, :destroy]
    resources :tasks
  end

  resources :offers, only: [:index] do
    member do
      get :customer_decision
      post :customer_decisions
    end
  end
  
  namespace :reports do
    get :weekly
    get :pipeline
  end

  # Pipeline Kanban board
  get 'pipeline', to: 'pipeline#index'
  patch 'pipeline/:id/update_status', to: 'pipeline#update_status', as: 'update_pipeline_status'

  # Letter opener web (development only)
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
