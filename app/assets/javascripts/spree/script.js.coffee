$ ->

  if ('.js-more-details').length > 0
    $(document).on
      click: (e) ->
        $('#more_details').modal('show')
        data = $(@).data('modal-target')
        console.log('data')
        $("a[href=##{data}]").click()
    , '.js-more-details'



  if ($ '#checkout_form_payment').is('*')
    ($ 'input[type="radio"][name="order[payments_attributes][][payment_method_id]"]').click(->
      ($ '#payment-methods li').hide()
      ($ '#payment_method_' + @value).show() if @checked
    )


    ($ '#cvv_link').on('click', (event) ->
      window_name = 'cvv_info'
      window_options = 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1'
      window.open(($ this).attr('href'), window_name, window_options)
      event.preventDefault()
    )

    # Activate already checked payment method if form is re-rendered
    # i.e. if user enters invalid data
    ($ 'input[type="radio"]:checked').click()

    ($ 'input#order_use_billing').click(->
      if ($ this).is(':checked')
        ($ 'input[type="submit"][value="Checkout"][data-hook="one_page_checout_button"]').css("margin-left", "10px")
        ($ '#shipping_method_wrapper').removeClass('alpha')
        ($ '#shipping_method_wrapper').addClass('omega')
      else
        ($ 'input[type="submit"][value="Checkout"][data-hook="one_page_checout_button"]').css("margin-left", "0")
        ($ '#shipping_method_wrapper').removeClass('omega')
        ($ '#shipping_method_wrapper').addClass('alpha')
    ).triggerHandler 'click'
    # deface cannot did it
    ($ 'button#checkout-link').remove()

    fetch_available_shipping_methods = (params_shippment) ->
      $.ajax
        type: 'POST'
        dataType: 'html'
        url: $('#shipping_method').data('url')
        data: params_shippment
        beforeSend: ( jqXHR ) ->
          $('#methods .time-load').show()
        success: (data) ->
          if data? && data.length
            console.log('dziala')
            $('#methods').html data
          else
            console.log('error')
            $('#methods').html "<center><p class='info'> #{$('#shipping_method').data('not-delivery')} </p></center>"

    $('#check-shipping-methods').click(->
      params = {}
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

      fetch_available_shipping_methods(params)
    ).triggerHandler 'click'
