Rails.application.routes.draw do
  post 'users/upload', to: 'users#upload'
  root 'users#index'
end
