Spree::Order.class_eval do
  attr_accessor :room_cookie
  checkout_flow do
    remove_checkout_step :address
    remove_checkout_step :delivery
    remove_checkout_step :payment
    remove_checkout_step :confirm
    go_to_state :complete
  end



  def generate_shipment_adjustments

    shipments = self.shipments
    if  shipments.present?
      shipments.each do |shipment|
        rate = shipment.shipping_rates.where(selected: true).first

        if rate.present?
          shipment.update_attributes({selected_shipping_rate_id: rate.id, cost: rate.cost})
        end

        if shipment.adjustments.present?
          shipment.adjustments.destroy_all
        end

        shipment.adjustments.create(amount: shipment.cost, source_type: 'Spree::Order', order_id: self.id, label: 'Shipment')
      end
    end
  end

end
