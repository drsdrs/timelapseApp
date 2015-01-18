(function() {
  var App;

  App = {};

  App.socket = io.connect();

  App.socket.on('refreshImg', function(data) {
    var img, imgCnt, link;
    imgCnt = data.imgCnt;
    img = $("#mainImg");
    if (!data.captureRunning) {
      link = "captured/" + imgCnt + ".jpg" + "?" + Date.now();
    } else {
      link = "captured/" + imgCnt + ".jpg";
      $("#imgBox").append("<img src='" + link + "' width='40' height='30'>");
    }
    return img.attr("src", link);
  });

  App.socket.on("movieList", function(list) {
    $("#movBox").empty();
    return list.forEach(function(movie) {
      return $("#movBox").append("<video src='converted/" + movie + "' width='300' height='200' preload controls></video>");
    });
  });

  $(function() {
    $("#movieName").val("default-" + ((Date.now() * Math.random() & 8191).toString(36)));
    $("#convert").click(function(e) {
      var data;
      $("#imgBox").empty();
      data = {
        name: $("#movieName").val(),
        fps: $(".fps").val()
      };
      return App.socket.emit('convert', data);
    });
    $("#start").click(function(e) {
      return App.socket.emit('start');
    });
    $("#stop").click(function(e) {
      return App.socket.emit('stop');
    });
    $(".fps").change(function(e) {
      return $(".fps").val(e.target.value);
    });
    $(".captureDelay").change(function(e) {
      var val;
      val = e.target.value;
      if (val < 3) {
        val = 3;
      }
      $(".captureDelay").val(val);
      return App.socket.emit('captureDelay', val);
    });
    return App.socket.emit("clientReady");
  });

}).call(this);
