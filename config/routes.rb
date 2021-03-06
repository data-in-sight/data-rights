Rails.application.routes.draw do

  mount Blazer::Engine, at: "reports"

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.can?(:admin_login) } do
    mount Sidekiq::Web => '/sidekiq'
  end

  get 'content/:template_type', :to => 'dynamic#authorized_content'
  get 'content/public/:template_type', :to => 'dynamic#anonymous_content'

  get 'events/:id', :to => 'events#find'

  post 'organizations', :to => 'organization#create'

  get 'languages/set'

  get 'faq/index'

  get 'consents/index'

  get 'consents/show'

  delete 'consent/:id/revoke', :to => 'consents#revoke', as: 'revoke_consent'

  get 'notifications/index'
  get 'notifications/settings'
  match 'notifications/update', to: 'notifications#update', via: [:patch, :put]

  get 'errors/not_found'
  get 'errors/internal_server_error'
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  get 'correspondence/:id/download', to: 'correspondences#download', as: 'download_correspondence'

  resources :campaigns, only: [:index] do
    resources :access_requests, except: [:delete, :show]
    get 'access_requests/existing', to: 'access_requests#new'
  end

  post 'access_request/:id/comment', to: 'access_requests#comment', as: 'access_request_comment'
  get 'access_requests/preview'
  get 'access_request/:id/download', to: 'access_requests#download', as: 'downlaod_access_request'
  get 'access_request/:id/template/:template_type', to: 'access_requests#template', as: 'access_request_template'
  get 'access_request/possible_templates/:organization_id', to: 'access_requests#possible_templates', as: 'access_request_possible_templates'
  get 'campaigns/:id/organizations/:sector_id', to: 'campaigns#get_organizations', as: 'get_campaign_organizations'
  get 'campaigns/:id/organizations/:organization_id/template/:template_id', to: 'campaigns#get_organization_template', as: 'get_campaign_organization_template_with_lang'
  get 'campaigns/:id/organizations/:organization_id/template', to: 'campaigns#get_organization_template', as: 'get_campaign_organization_template'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { :invitations => 'users/invitations', :registrations => 'users/registrations' }

  # Workflow
  get 'workflow/diagram/:id', to: 'workflow#diagram'
  post 'workflow', to: 'workflow#send_event'
  patch 'workflow', to: 'workflow#send_event'
  post 'workflow/undo/:access_request_step_id', to: 'workflow#undo'

  # access_request_steps
  patch 'access_request_step', to: 'access_request_step#update'

  get 'user/profile/edit', to: 'users#edit'
  get 'user/profile/campaign/:campaign_id', to: 'users#edit', as: 'user_profile_for_campaign'
  match 'users/profile', to: 'users#update', via: [:patch, :put]
  get 'users/tfa'
  post 'users/enable_otp'
  post 'users/disable_otp'
  get 'user/has_otp', to: 'users#has_otp'

  root 'home#index'
  get 'home', to: 'home#index'

  resources :attachments
  get 'attachments/:id/content', to: 'attachments#get_content', as: 'get_content'
  post 'attachments/:id/content', to: 'attachments#post_content', as: 'post_content'
  post 'attachments/content', to: 'attachments#new_content', as: 'new_content'

  get 'attachments/:id/thumbnail', to: 'attachments#thumbnail', as: 'thumbnail'

  get 'discourse/sso' => 'discourse_sso#sso'
end
