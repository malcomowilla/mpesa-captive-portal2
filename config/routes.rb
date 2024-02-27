Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/stk_push', to: 'stk_push#initiate_stk_push'
  # post '/stk_push2', to: 'stk_push2#initiate_stk_push2'
  # post '/stk_push3', to: 'stk_push3#initiate_stk_push3'

end
