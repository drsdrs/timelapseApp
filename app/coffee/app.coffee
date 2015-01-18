App = {}
App.socket = io.connect()


# Draw from other sockets
App.socket.on 'refreshImg', (data)->
  imgCnt = data.imgCnt
  img = $("#mainImg")
  if !data.captureRunning
    link = "captured/"+imgCnt+".jpg"+"?"+Date.now()
  else
    link = "captured/"+imgCnt+".jpg"
    $("#imgBox").append("<img src='"+link+"' width='40' height='30'>")

  img.attr("src", link)

App.socket.on "movieList", (list)->
  $("#movBox").empty()
  list.forEach (movie)->
    $("#movBox").append(
      "<video src='converted/"+movie+"' width='300' height='200'
      preload controls></video>"
    )


$(->
  # set random default name for movie
  $("#movieName").val "default-"+((Date.now()*Math.random()&8191).toString(36))

  $("#convert").click (e)->
    $("#imgBox").empty()
    data = {name:$("#movieName").val(), fps:$(".fps").val()}
    App.socket.emit('convert', data)

  $("#start").click (e)-> App.socket.emit('start')

  $("#stop").click (e)-> App.socket.emit('stop')

  $(".fps").change (e)->
    $(".fps").val(e.target.value)

  $(".captureDelay").change (e)->
    val = e.target.value
    if val < 3 then val = 3
    $(".captureDelay").val(val)
    App.socket.emit 'captureDelay', val

  App.socket.emit "clientReady"
)
