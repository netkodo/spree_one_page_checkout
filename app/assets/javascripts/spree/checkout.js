(function() {
    this.disableSaveOnClick = function() {
        return ($('form.edit_order')).submit(function() {
            return ($(this)).find(':submit, :image').attr('disabled', true).removeClass('primary').addClass('disabled');
        });
    };

    $(function() {
        var country_from_region ;

        if (($('#checkout_form_payment')).is('*')) {
            ($('#checkout_form_payment')).validate();
            country_from_region = function(region) {
                return ($('p#' + region + 'country' + ' span#' + region + 'country-selection :only-child')).val();
            };

//            ($('input#order_use_billing')).click(function() {
//                if (($(this)).is(':checked')) {
//                    ($('#shipping .inner')).hide();
//                    return ($('#shipping .inner input, #shipping .inner select')).prop('disabled', true);
//                } else {
//                    ($('#shipping .inner')).show();
//                    ($('#shipping .inner input, #shipping .inner select')).prop('disabled', false);
//                    if (get_states('s')) {
//                        return ($('span#sstate input')).hide().prop('disabled', true);
//                    } else {
//                        return ($('span#sstate select')).hide().prop('disabled', true);
//                    }
//                }
//            }).triggerHandler('click');
        }
        if (($('#checkout_form_payment')).is('*')) {
            ($('input[type="radio"][name="order[payments_attributes][][payment_method_id]"]')).click(function() {
                ($('#payment-methods li')).hide();
                if (this.checked) {
                    return ($('#payment_method_' + this.value)).show();
                }
            });
            ($(document)).on('click', '#cvv_link', function(event) {
                var window_name, window_options;

                window_name = 'cvv_info';
                window_options = 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1';
                window.open(($(this)).attr('href'), window_name, window_options);
                return event.preventDefault();
            });
            return ($('input[type="radio"]:checked')).click();
        }
    });

}).call(this);
