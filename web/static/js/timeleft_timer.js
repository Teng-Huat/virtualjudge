if (document.getElementsByClassName("countdown").length > 0){
  var elems = document.getElementsByClassName("countdown")
  setInterval(function() {
    Array.prototype.forEach.call(elems, function(elem) {
      var endtime = parseInt(elem.dataset.countdown)
      endtime = new Date(endtime)
      var now = new Date().getTime()
      var distance = endtime - now
      var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
      var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60))
      var seconds = Math.floor((distance % (1000 * 60)) / 1000)
      elem.innerHTML = hours + "h " + minutes + "m " + seconds + "s "
      if (distance < 0) {
        elem.innerHTML = "Times up!"
      }
    });
  }, 1000);
}
