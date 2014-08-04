Spree::CheckoutController.class_eval do

  #skip_filter(:check_registration)

  #helper 'spree/products'

  # For payment step, filter order parameters to produce the expected nested
  # attributes for a single payment and its source, discarding attributes
  # for payment methods other than the one selected
  def object_params
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
      @order.create_proposed_shipments
      if params[:shipping_method_id].present?
        shipping_rate = @order.shipments.first.shipping_rates.where(shipping_method_id: params[:shipping_method_id]).first
        @order.shipments.first.selected_shipping_rate_id = shipping_rate.id
      end
      # инициализируем фамилию
      if params[:order][:bill_address_attributes]
        params[:order][:bill_address_attributes][:address1] = 'Тверь' if params[:order][:bill_address_attributes][:address1].blank?
        params[:order][:bill_address_attributes][:lastname] = 'Фамилия' if params[:order][:bill_address_attributes][:lastname].blank?
      end
      params[:order].permit(permitted_checkout_attributes)
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
