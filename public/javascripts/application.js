// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

(function($){
  $.fn.domIndex = function() {
     return this.siblings().size()-this.nextAll().size() + 1;
  };
})(jQuery);

$(document).ready(function()
{
    $('td input[type="checkbox"]').click(function(){
        if ($(this).is(':checked')){
             $(this).parent().parent().addClass('highlighted');
        } else if($(this).parent().parent().is('.highlighted')) {
             $(this).parent().parent().removeClass('highlighted');
        }
    });
    $('th input[type="checkbox"]').click(function(){
        index = $(this).parent().domIndex()
        selector = 'td:nth-child(' + index + ') > input[type=checkbox]'
        checkboxes = $(this).parents('table').find(selector)

        if ($(this).is(':checked')){
            checkboxes.attr('checked', true)
            checkboxes.parent().parent().addClass('highlighted')
        } else {
            checkboxes.attr('checked', false)
            checkboxes.parent().parent().removeClass('highlighted')
        }
    });
});