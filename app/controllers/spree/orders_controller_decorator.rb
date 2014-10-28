Spree::OrdersController.class_eval do

  def edit
    @order = current_order
    # associate_user
    # if @order.present? and @order.bill_address_id.blank?
    #   @order.bill_address ||= Spree::Address.default
    # end
    # if @order.present? and @order.ship_address.blank?
    #   @order.ship_address ||= Spree::Address.default
    # end
    # # before_delivery
    # @order.payments.destroy_all if request.put?
  end

  # change this to alias / spree

  def one_page_checkout
    @order = current_order
    associate_user
    if @order.present? and @order.bill_address_id.blank?
      @order.bill_address ||= Spree::Address.default
    end
    if @order.present? and @order.ship_address.blank?
      @order.ship_address ||= Spree::Address.default
    end
    # before_delivery
    @order.payments.destroy_all if request.put?
  end


end
