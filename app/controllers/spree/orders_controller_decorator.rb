Spree::OrdersController.class_eval do
  def edit
    @order = current_order
    @order.adjustments.delete_all
    @order.update_promotion
    if @order.present?
      if @order.shipments.present?
        @order.update(shipment_total: @order.shipments.sum(&:cost))
      end
      @order.update(total: @order.item_total + @order.adjustment_total+ @order.additional_tax_total + @order.shipment_total + @order.promo_total)
    end
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

    @order.line_items.each do |item|
      if Spree::Variant.find_by(id: item.variant_id).product.quantity_on_hand == 0
        flash[:error] = "You have items in cart which are no longer available, please remove them"
        redirect_to cart_path
      end
    end

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
        @order.update(shipment_total: @order.shipments.sum(&:cost))
        @order.update(total: @order.item_total + @order.adjustment_total+  @order.additional_tax_total + @order.shipment_total + @order.promo_total)

      else
        redirect_to cart_path
      end
    else
      redirect_to cart_path
    end
  end

  def check_adjustments
    @order = current_order

    p = nil
    promotions=Spree::PromotionRule.where(type:"Spree::Promotion::Rules::ItemTotal")
    promotions.each do |promo|
      if promo.promotion.name == "FREE SHIPPING"
        p = promo
      end
    end

    if p.present?
      if p.eligible?(@order)
        @order.payments.destroy_all if request.put?
        @order.update_totals
        @order.update(shipment_total: @order.shipments.sum(&:cost))
        @order.update(total: @order.item_total + @order.adjustment_total+  @order.additional_tax_total + @order.shipment_total + @order.promo_total)
      end
    end
  end

  def set_shipping_rate
    respond_to do |format|
      @order = current_order
      shipment = @order.shipments.where(id: params[:shipment_id]).first
      rate = shipment.shipping_rates.where(id: params[:id]).first
      rate.update(selected: true)
      shipment.update(selected_shipping_rate_id: rate.id, cost: rate.cost)
      @order.generate_shipment_adjustments
      @order.update(shipment_total: @order.shipments.sum(&:cost))
      @order.update(total: @order.item_total + @order.adjustment_total +  @order.additional_tax_total + @order.shipment_total + @order.promo_total)
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
