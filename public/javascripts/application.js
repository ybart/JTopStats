// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function()
{
    $('td input[type="checkbox"]').click(function(){
        if ($(this).is(':checked')){
             $(this).parent().parent().addClass('highlighted');
        } else if($(this).parent().parent().is('.highlighted')) {
             $(this).parent().parent().removeClass('highlighted');
        }
    });
});