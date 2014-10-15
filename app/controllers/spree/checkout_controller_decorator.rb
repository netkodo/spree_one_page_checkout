Spree::CheckoutController.class_eval do

  #skip_filter(:check_registration)

  #helper 'spree/products'

  # For payment step, filter order parameters to produce the expected nested
  # attributes for a single payment and its source, discarding attributes
  # for payment methods other than the one selected


  def update
    @order.update_attribute(:state, 'cart')
    if params[:shipments_attributes].present?
      params[:shipments_attributes].each do |key, value|

        shipment = @order.shipments.where(id: value[:id]).first
        rate = shipment.shipping_rates.where(id: value[:selected_shipping_rate_id]).first
        shipment.update_attributes({selected_shipping_rate_id: rate.id, cost: rate.cost})

      end
      @order.adjustments.shipping.create(amount: @order.shipments.sum(:cost), label: 'Shipment')
      if @order.update_from_params(params, permitted_checkout_attributes)
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
    ship_params = {}
    bill_params = {}
    state = [:cart, :address]
    if params[:state_id].present?
      @order = current_order(lock: true)
      if @order.shipments.present?
        @order.shipments.destroy_all
      end

      @order.update_attribute(:state, 'address')

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
      @order.update_from_params(@params, permitted_checkout_attributes)
      @order.before_my_delivery
      if @order.errors.blank?
        @order.update_from_params({"state" => "delivery"}, permitted_checkout_attributes)
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
