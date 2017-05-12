Spree::CheckoutController.class_eval do

  skip_filter(:check_registration)

  #helper 'spree/products'

  # For payment step, filter order parameters to produce the expected nested
  # attributes for a single payment and its source, discarding attributes
  # for payment methods other than the one selected


  def update

    @order.update_attribute(:state, 'cart')
    if params[:shipments_attributes].present?
      if cookies[:board_id].present?
        @order.room_cookie = cookies[:board_id]
      end
      #params[:shipments_attributes].each do |key, value|
      #
      #  shipment = @order.shipments.where(id: value[:id]).first
      #  if  shipment.present?
      #    rate = shipment.shipping_rates.where(id: value[:selected_shipping_rate_id]).first
      #
      #    if rate.present?
      #      shipment.update_attributes({selected_shipping_rate_id: rate.id, cost: rate.cost})
      #    end
      #  end
      #  shipment.adjustments.create(amount: shipment.cost, source_type: 'Spree::Order', order_id: @order.id, label: 'Shipment')
      #
      #  #if @order.adjustments.where(label: 'Shipment').blank?
      #  #@order.adjustments.shipping.create(amount: @order.shipments.sum(:cost), source_type: 'Spree::Shipment' ,label: 'Shipment')
      #  #end
      #end
      if @order.update_from_params(params, permitted_checkout_attributes)
        persist_user_address
        unless @order.next

          flash[:error] = @order.errors.full_messages.join("\n")
          redirect_to one_page_checkout_path and return
        end

        if @order.completed?
          @order.payments.destroy_all if request.put?
          @order.update_totals
          # @order.update(shipment_total: @order.shipments.sum(&:cost))
          shipment_total = @order.shipments.sum(&:cost)
          @order.update(total: @order.item_total + @order.adjustment_total+  @order.additional_tax_total + shipment_total + @order.promo_total,shipment_total: shipment_total)
          @order.deliver_order_confirmation_email unless @order.confirmation_delivered?
          # Rails.logger.info session[:order_id]
          # session[:order_id] = nil
          if @order.subscribe == true
            @subscriber = Spree::Subscriber.find_by_email(@order.email)
            if @subscriber.present?
              @subscriber.update_attribute("last_subscribed_at", Time.now)
            else
              sub = Spree::Subscriber.create(:email => @order.email, :last_subscribed_at => Time.now)
              Rails.logger.info "ADDED TO MAILCHIMP LIST" if sub.add_subscriber_to_mailchimp('subscribers')
            end
          end

          flash.notice = Spree.t(:order_processed_successfully)
          flash[:commerce_tracking] = "nothing special"

          redirect_to order_confirmation_path
        else
          redirect_to checkout_state_path(@order.state)
        end
      else

        render :edit
      end
    else
      @order.errors.add(:shipments, "Can't be blank")
      flash[:error] = @order.errors.full_messages.join("\n")
      redirect_to cart_path
    end

  end




  def generate_shipments
    ship_params = {}
    bill_params = {}
    @is_check = @order.include_custom_product?
    @order.update(email: params[:email]) if params[:email].present?
    state = [:cart, :address]
    if params[:state_id].present?
      @order = current_order(lock: true)
      if @order.adjustments.where(adjustable_type: 'Spree::Shipment').present?
      @order.adjustments.where(adjustable_type: 'Spree::Shipment').destroy_all
      end

      if params[:bill_id].present?
        bill_params = params.dup
        bill_params[:id] = params[:bill_id]
      else
        bill_params = params
      end

      if params[:ship_id].present?
        ship_params = params.dup
        ship_params[:id]= params[:ship_id]
      else
        ship_params = params
      end
      all_params = {order: {bill_address_attributes: bill_params, ship_address_attributes: ship_params}, state: "address", save_user_address: 1}
      @params = ActionController::Parameters.new(all_params.except!(:controller, :action, :bill_id, :ship_id))


      @order.update_attribute(:state, 'address')
      @order.update_from_params(@params, permitted_checkout_attributes)

      @order.create_tax_from_cloud!

      # @order.order_ac_event("PaymentPage")  #Camecase coz inside method undersore

      p = nil
      promotions=Spree::PromotionRule.where(type:"Spree::Promotion::Rules::ItemTotal")
      promotions.each do |promo|
        if promo.promotion.name == "FREE SHIPPING"
          p = promo
        end
      end

      if p.present?
        p.eligible?(@order) ? @new_ship_price = true : @new_ship_price = false
      end

      Rails.logger.info @order.shipment_adjustments.promotion.inspect
      Rails.logger.info @order.shipment_adjustments.promotion.inspect
      Rails.logger.info @order.shipment_adjustments.promotion.inspect

      if @order.errors.blank?
        @order.before_my_delivery
        @order.check_tax!
        @order.update_from_params({"state" => "delivery"}, permitted_checkout_attributes)
        @order.generate_shipment_adjustments
      else
        render 'generate_shipments'
      end

    end
  end


  def object_params_checkout
    if @params[:order]
      @params[:order].permit(permitted_checkout_attributes)
    else
      {}
    end

  end


  private

  def skip_state_validation?
    true
  end


end
