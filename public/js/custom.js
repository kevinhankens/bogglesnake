/**
 * bogglesnake class handles some basic dom bindings.
 */
var bogglesnake = {
  'bgColor' : '#fff',
  'fontColor' : '#000',
  'setup' : function() {
    this.bgColor = $('.letterinput').css('backgroundColor');
    this.fontColor = $('.letterinput').css('color');
    this.bindHover();
    $('.letterinput').click(function() {
      $(this).select();
    });
  },
  'bindHover' : function() {
    // Bind a mouseover event to show each word path to the user.
    $('.word').mouseover(function() {
      var pathString = $(this).data('path');
      var pathList = pathString.split(',');
      for (var i = 0; i < pathList.length; i++) {
        $(this).css({'color' : '#fff', 'backgroundColor' : '#369'})
        $('#input-' + pathList[i]).css({'color' : '#fff', 'backgroundColor' : '#369'});
      }
    });

    // Revert the styling on mouseout.
    $('.word').mouseout(function() {
      $(this).css({'color' : bogglesnake.fontColor, 'backgroundColor' : bogglesnake.bgColor})
      $('.letterinput').css({'color' : bogglesnake.fontColor, 'backgroundColor' : bogglesnake.bgColor});
    });
  }
}

$(document).ready(function() {

  bogglesnake.setup();

  // Bind to user input changes.
  $('.letterinput').bind('change keyup input', function() {
    var values = new Array(5);
    for (var i = 0; i < 5; i++) {
      values[i] = new Array(5);
    }

    var inputOk = true;
    $('.letterinput').each(function(i, e) {
      // Capture each of the letters input and do a sanity check.
      var element = $(e);
      var row = element.data('row');
      var col = element.data('col');
      var value = element.val();
      // Only alpha
      var pattern=/[a-z]{1}/
      if (!pattern.test(value)) {
        if (value != "") {
          alert('Please only use the letters a-z');
        }
        inputOk = false;
      }
      values[row][col] = value.toLowerCase();
    });

    // If the input is sane, send the letters to the server to search.
    if (inputOk) {
      $.ajax({
        'url' : '/submit',
        'type' : 'GET',
        'dataType' : 'json',
        'data' : {'values' : values},
        'success' : function(data, status, xhr) {
          $('#words').html(data.words);
          bogglesnake.bindHover();
        }
      });
    }
  });

});
