Spree::Core::Engine.routes.draw do

  resources :orders do
    collection do
      post :set_shipping_rate
    end
  end
  # post 'ajax/order/available_shipping_methods' => 'shipping_methods#index', :as => :available_shipping_methods
  post 'ajax/order/available_shipping_methods' => 'checkout#generate_shipments', :as => :available_shipping_methods

  get 'one_page_checkout', to: 'orders#one_page_checkout', as: :one_page_checkout
  post 'check_adjustments', to: 'orders#check_adjustments', as: :check_adjustments
  post 'set_store_credit', to: 'orders#set_store_credit', as: :set_store_credit
end