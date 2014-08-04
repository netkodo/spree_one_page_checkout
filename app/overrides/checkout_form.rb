#Deface::Override.new(:virtual_path => "spree/orders/edit",
                     #:insert_after => '#empty-cart[data-hook]',
                     #:template => "spree/orders/one_page_checkout",
                     #:name => "checkout_form",
                     #:original => 'e36b7d08e8dd32225b0dc75e5bfee8afda5c9a65')
#Deface::Override.new(:virtual_path => "spree/orders/edit",
                     #:replace => "[data-hook = 'cart_items']",
                     #:text => '<%= render :partial => "spree/orders/form", :locals => { :order_form => order_form } %>',
                     #:name => "rename_cart_form",
                     #:original => '8ddfc4e61a954ffb7016b15997c4785947cc6f64')
#Deface::Override.new(:virtual_path => "spree/orders/_form",
                     #:replace => "tbody#line_items",
                     #:partial => "spree/orders/line_items_fix",
                     #:name => "rename_line_items_form",
                     #:original => 'a0476f87d5cfd69d3b2039de96babb77bf97a324')
# Deface::Override.new(:virtual_path => "spree/orders/edit",
#                      :remove => "code[erb-loud]:contains('button_tag :class => 'button checkout primary', :id => 'checkout-link', :name => 'checkout'')",
#                      :name => "remove_checkout_button")
