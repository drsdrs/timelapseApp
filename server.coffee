express = require("express.io")
app = express().http().io()

spawn = require('child_process').spawn
fs = require('fs')
#play = require("./helper/play.coffee")()

c = console; c.l = c.log


app.use(express.static(__dirname+"/app"))
app.use(express.static(__dirname+"/media"))

# Send client html.
app.get "/", (req, res) -> res.sendfile __dirname + "/app/index.html"
app.get "/removeImages", (req, res) -> removeImages()

avconv = require('avconv')

captureRunning = false
imgCnt = 0
captureDelay = 1

intervalObj = {}

startInterval = (delaySec)->
  intervalObj = setInterval((-> captureImage()), delaySec*1000)


sendMovieList = () ->
  data = {a:12, b:123}
  fs.readdir "media/converted", (err, files)->
    if err then c.l err
    app.io.broadcast "movieList", files


duringCapture = false

captureImage = ->
  if duringCapture
    return console.log("Cant go faster")
  else duringCapture = true
  if captureRunning then imgCnt++

  spawn("raspistill", [
      "-t", "2000" # timeout
      "-w", "400"
      "-h", "300"
      "-o", "media/captured/"+(imgCnt)+".jpg"
    ]
  ).on "close", (code, signal) ->
    c.l "exit "+imgCnt
    duringCapture = false
    data = {imgCnt: imgCnt, captureRunning: captureRunning}
    app.io.broadcast "refreshImg", data

convertImg2Mov = (data)->
  imgCnt = 0
  captureRunning = false
  paramsImg2Mov = [
    "-f", "image2"
    "-r", data.fps
    "-i", "media/captured/%d.jpg"
    "media/converted/"+data.name+".mp4"
    "-y"
  ]
  stream = avconv(paramsImg2Mov)
  stream.on "exit", () ->
    c.l "movie done"
    sendMovieList()

removeImages = ->
  c.l "removeImages"
  spawn("rm", ["media/captured", "-r"])
    .on "close", (code, signal) ->
      spawn("mkdir", ["media/captured"])

## IO EVENTS

app.io.route "clientReady", (req) ->
  c.l "clientReady !!!"
  captureImage()
  startInterval 3
  sendMovieList()

app.io.route "convert", (req) ->convertImg2Mov(req.data)
app.io.route "start", (res) -> captureRunning= true
app.io.route "stop", (res) -> captureRunning= false
app.io.route "captureDelay", (res) ->
  clearInterval intervalObj
  startInterval res.data
  captureImage()




app.listen 9000
console.log "listening to 9000"
