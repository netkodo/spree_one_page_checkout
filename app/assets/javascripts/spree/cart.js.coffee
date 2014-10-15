$ ->

  if $('#order_use_billing').is(':checked')
    $(".js-shipment_form").hide()
  else
    $(".js-shipment_form").show()

  $(document).on
    click: (e)->
      if $(@).is(':checked')
        $(".js-shipment_form").hide()
      else
        $(".js-shipment_form").show()

  , "#order_use_billing"

  $(document).on
    click: (e)->
      e.preventDefault()
      $('.inner').each ()->
        $(@).slideUp()
      $('#payment .inner').slideDown()
  , '.js-next-payment'

  $(document).on
    click: (e)->
      e.preventDefault()
      shipping = $(@).data('check')
      next = $(@).data('next')
      if next?
        my_this = $('#shipping_method legend')
      else
        my_this = $(@)
      $('.inner').each ()->
        $(@).slideUp()
      if shipping? and shipping == 'shipping'
        if $('#order_use_billing').is(':checked')
           checkAddress('billing', my_this )
        else
           checkAddress('shipping', my_this)
      else
        $(".inner", $(@).parents('fieldset')).slideToggle()


  , ".js-bookmark, .js-shipping-sub"



checkAddress = (value, my_this)->
  params = {}
  params['bill_id'] = $('#order_bill_address_attributes_id').val()
  params['ship_id'] = $('#order_ship_address_attributes_id').val()
  if $('input#order_use_billing').is(':checked')
    params['country_id'] = $('#order_bill_address_attributes_country_id').val()
    params['state_id'] = $('#order_bill_address_attributes_state_id').val()
    params['firstname'] = $('#order_bill_address_attributes_firstname').val()
    params['lastname'] = $('#order_bill_address_attributes_lastname').val()
    params['address1'] = $('#order_bill_address_attributes_address1').val()
    params['city'] = $('#order_bill_address_attributes_city').val()
    params['zipcode'] = $('#order_bill_address_attributes_zipcode').val()
    params['phone'] = $('#order_bill_address_attributes_phone').val()

  else
    params['country_id'] = $('#order_ship_address_attributes_country_id').val()
    params['state_id'] = $('#order_ship_address_attributes_state_id').val()
    params['firstname'] = $('#order_ship_address_attributes_firstname').val()
    params['lastname'] = $('#order_ship_address_attributes_lastname').val()
    params['address1'] = $('#order_ship_address_attributes_address1').val()
    params['city'] = $('#order_ship_address_attributes_city').val()
    params['zipcode'] = $('#order_ship_address_attributes_zipcode').val()
    params['phone'] = $('#order_ship_address_attributes_phone').val()
  value_check = true
  $("[id$=#{value}] input.required").each ()->
    if $(@).val() == ""
      value_check = false
      return false
  if value_check == false
    $("[id$=#{value}] .inner").slideToggle()
  else

    fetch_available_shipping_methods(params)
    $(".inner", my_this.parents('fieldset')).slideToggle()


fetch_available_shipping_methods = (params_shippment) ->
  $.ajax
    type: 'POST'
    dataType: 'html'
    url: $('#shipping_method').data('url')
    data: params_shippment
    beforeSend: ( jqXHR ) ->
      $('#methods').html '<center><img src="assets/spinner.gif" alt="loading..." class="one-page-checkout-loader"></center>'
    success: (data) ->
      if data? && data.length
        $('#methods').html data
      else
        $('#methods').html "<center><p class='info'> #{$('#shipping_method').data('not-delivery')} </p></center>"