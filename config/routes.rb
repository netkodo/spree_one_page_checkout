Spree::Core::Engine.routes.draw do
  # post 'ajax/order/available_shipping_methods' => 'shipping_methods#index', :as => :available_shipping_methods
  post 'ajax/order/available_shipping_methods' => 'checkout#generate_shipments', :as => :available_shipping_methods
end