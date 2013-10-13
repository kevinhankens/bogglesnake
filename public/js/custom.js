var bogglesnake = {
  'bgColor' : '#fff',
  'fontColor' : '#000',
  'setup' : function() {
    this.bgColor = $('.letterinput').css('backgroundColor');
    this.fontColor = $('.letterinput').css('color');
    this.bindHover();
  },
  'bindHover' : function() {
    $('.word').mouseover(function() {
      var pathString = $(this).data('path');
      var pathList = pathString.split(',');
      for (var i = 0; i < pathList.length; i++) {
        $(this).css({'color' : '#fff', 'backgroundColor' : '#369'})
        $('#input-' + pathList[i]).css({'color' : '#fff', 'backgroundColor' : '#369'});
      }
    });

    $('.word').mouseout(function() {
      $(this).css({'color' : bogglesnake.fontColor, 'backgroundColor' : bogglesnake.bgColor})
      $('.letterinput').css({'color' : bogglesnake.fontColor, 'backgroundColor' : bogglesnake.bgColor});
    });
  }
}

$(document).ready(function() {

  bogglesnake.setup();

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
        $('#words').html(data.words);
        bogglesnake.bindHover();
      }
    });
  });

});
