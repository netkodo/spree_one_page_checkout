Spree::Order.class_eval do
  attr_accessor :room_cookie
  attr_accessor :portfolio_cookie
  checkout_flow do
    remove_checkout_step :address
    remove_checkout_step :delivery
    remove_checkout_step :payment
    remove_checkout_step :confirm
    go_to_state :complete
  end

  def get_white_glove_price
    total = self.item_total
    if (0..500).include? total
      return Money.new(9900, self.currency).amount
    elsif (500.01..1000).include? total
      return Money.new(11900, self.currency).amount
    elsif (1000.01..1500).include? total
      return Money.new(15900, self.currency).amount
    elsif (1500.01..2000).include? total
      return Money.new(19900, self.currency).amount
    elsif (2000.01..3000).include? total
      return Money.new(22900, self.currency).amount
    elsif (3000.01..BigDecimal::INFINITY).include? total
      return Money.new(24900, self.currency).amount
    end
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

  def include_custom_product?
    f = false
    self.line_items.each do |item|
      if item.variant.present? and item.variant.made_to_order?
        f = true
        break
      end
    end
    f
  end

  def sort_order_shipments_by_shipping_method
    shipment_sorted = {}
    # Gathering uniq shipping methods which occur in shipments, then sorting freight items as last, and then creating
    # shipments sorted by shipment method
    all_shipping_methods = self.shipments.map{|x| x.shipping_methods.where.not(name: 'White Glove Shipping').pluck(:id)}.flatten.uniq
    all_shipping_methods = Spree::ShippingMethod.set_freight_items_as_last(all_shipping_methods)
    all_shipping_methods.each do |id|
      shipment_sorted[id] = self.shipments.joins(:shipping_methods).where('spree_shipping_methods.id = ?', id)
    end
    shipment_sorted
  end

end
