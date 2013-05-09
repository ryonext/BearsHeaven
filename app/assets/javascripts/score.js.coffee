window.sendScore = (score, difficulty) ->
  $("#confirmDialog").dialog
    bgiframe: true,
    autoOpen: true,
    width: 300,
    modal: true,
    buttons: {
      'OK': ->
        postScore(score, difficulty, $("#name").val())
        $(this).dialog('close')
    }
  
postScore = (score, difficulty, name) ->
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
      }
    }
    success: ->
      alert "success"
