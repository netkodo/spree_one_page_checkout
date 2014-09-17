Spree::CheckoutController.class_eval do
  #skip_filter(:check_registration)

  #helper 'spree/products'

  # For payment step, filter order parameters to produce the expected nested
  # attributes for a single payment and its source, discarding attributes
  # for payment methods other than the one selected
  def object_params
    @order.state ='cart'
    # has_checkout_step? check is necessary due to issue described in #2910
    if @order.has_checkout_step?("payment") && @order.payment?
      if params[:payment_source].present?
        source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].underscore]

        if source_params
          params[:order][:payments_attributes].first[:source_attributes] = source_params
        end
      end

      if (params[:order][:payments_attributes])
        params[:order][:payments_attributes].first[:amount] = @order.total
      end
    end
    if params[:order]

      if params[:shipments_attributes].present?
        params[:shipments_attributes].each do |key, value|
          shipment = @order.shipments.where(id: value[:id]).first
          rate = shipment.shipping_rates.where(id: value[:selected_shipping_rate_id]).first
          shipment.selected_shipping_rate_id = rate.id
        end
        params[:order].permit(permitted_checkout_attributes)
      else
        {}
      end

    end

  end

  def update
    if params[:shipments_attributes].present?
    if @order.update_attributes(object_params)
      persist_user_address

      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end


      if @order.completed?
        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route
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
    state = [:cart, :address]
    if params[:state_id].present?
      @order = current_order
      if @order.shipments.present?
        @order.shipments.destroy_all
      end
      @order.update_attribute(:state, 'address')
      return_params = params.except!(:controller, :action)
      address = Spree::Address.create(return_params)
      ship_params = {order: {bill_address_attributes: return_params, ship_address_attributes: address.attributes}, state: "address"}
      @params = ActionController::Parameters.new(ship_params)
      @order.update_attributes(object_params_checkout)

      state.each do |state|
        @order.state = state
        setup_for_current_state
      end
      @order.before_my_delivery
      if @order.errors.blank?
        @order.update_attribute(:state, 'delivery')
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


## change this to alias / spree
#def object_params
#unless params[:order][:payments_attributes].nil?
#if params[:payment_source].present? && source_params = params.delete(:payment_source)[params[:order][:payments_attributes].first[:payment_method_id].try(:underscore)]
#params[:order][:payments_attributes].first[:source_attributes] = source_params
#end
#end
#if (params[:order][:payments_attributes])
#params[:order][:payments_attributes].first[:amount] = @order.total
#end
#if params[:order]
##params[:order][:bill_address_attributes][:country] = Spree::Country.find(params[:order][:bill_address_attributes].delete(:country_id)) if params[:order][:bill_address_attributes][:country_id].present?
#params[:order].permit(permitted_checkout_attributes)
#else
#{}
#end
#end


  private

  def skip_state_validation?
    true
  end

end
