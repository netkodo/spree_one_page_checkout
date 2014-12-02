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
    if @order.present?
      associate_user
      if @order.present?
        @order.discount_for_designer!

        if  @order.bill_address_id.blank?
          @order.bill_address ||= Spree::Address.default
        end
        if  @order.ship_address.blank?
          @order.ship_address ||= Spree::Address.default
        end
        # before_delivery
        @order.payments.destroy_all if request.put?
        @order.update_totals

      else
        redirect_to cart_path
      end
    else
      redirect_to cart_path
    end
  end

  def check_adjustments
    @order = current_order
  end

  def set_shipping_rate
    respond_to do |format|
      @order = current_order
      shipment = @order.shipments.where(id: params[:shipment_id]).first
      rate = shipment.shipping_rates.where(id: params[:id]).first
      shipment.update(cost: rate.cost)
      format.json { render json: {message: 'OK'} }

    end
  end

  def set_store_credit
    respond_to do |format|
      @order = current_order
      if @order.user.store_credits.present? and @order.user.store_credits.sum(&:remaining_amount) > 0

        amount = params[:amount]
        remaining_amount = @order.user.store_credits.sum(&:remaining_amount)

        if amount.to_d > remaining_amount
          @order.update(store_credit_amount: remaining_amount)
        else
          @order.update(store_credit_amount: amount.to_d)
        end

      end
      format.json { render json: {message: 'OK'} }
    end
  end


end
