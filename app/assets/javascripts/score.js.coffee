window.sendScore = (score, difficulty) ->
  console.log(score)
  console.log(difficulty)
  $.ajax
    url: "/games",
    type: 'POST',
    dataType: 'json',
    timeout: 1000,
    data: {
      score: {
        name: 'hoge',
        point: score,
        difficulty: difficulty,
      }
    }
    success: ->
      alert "success"
