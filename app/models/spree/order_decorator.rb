Spree::Order.class_eval do

  checkout_flow do
    remove_checkout_step :address
    remove_checkout_step :delivery
    remove_checkout_step :payment
    remove_checkout_step :confirm
    go_to_state :complete
  end

end
