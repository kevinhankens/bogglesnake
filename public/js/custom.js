$(document).ready(function() {

  $('.letterinput').blur(function() {
    var values = new Array(5);
    for (var i = 0; i < 5; i++) {
      values[i] = new Array(5);
    }

    $('.letterinput').each(function(i, e) {
      var element = $(e);
      var row = element.data('row');
      var col = element.data('col');
      var value = element.val();
      values[row][col] = value;
    });

    $.ajax({
      'url' : '/submit',
      'type' : 'GET',
      'dataType' : 'json',
      'data' : {'values' : values},
      'success' : function(data, status, xhr) {
        console.log(data);
        $('.words').html(data.join(' '));
      }
    });
  });

});
