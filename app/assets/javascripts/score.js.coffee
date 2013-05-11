window.sendScore = (score, difficulty, magnification) ->
  $("#confirmDialog").dialog
    bgiframe: true,
    autoOpen: true,
    width: 300,
    modal: true,
    buttons: {
      'OK': ->
        postScore(score, difficulty, $("#name").val(), magnification)
        $(this).dialog('close')
    }
  
postScore = (score, difficulty, name, magnification) ->
  $.ajax
    url: "/games",
    type: 'POST',
    dataType: 'json',
    timeout: 1000,
    data: {
      score: {
        name:       name,
        point:      score,
        difficulty: difficulty,
        magnification: magnification
      }
    }
    success: ->
      $.notifyBar
        html: "success!",
        delay: 2000,
        animationSpeed: "normal"
