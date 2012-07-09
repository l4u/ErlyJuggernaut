(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $(document).ready(function() {
    var jug, log, logElement;
    logElement = $("#log");
    logElement.value = "";
    log = __bind(function(data) {
      return logElement.val(logElement.val() + data + "\n");
    }, this);
    log("Subscribing to channel1");
    jug = new ErlyJuggernaut();
    jug.on("connect", function() {
      log("Connected");
      return jug.subscribe("channel1", function(data) {
        return log("Got data: " + data);
      });
    });
    return jug.on("disconnect", function() {
      jug.unbind("channel1:data");
      return log("Disconnected");
    });
    /* TODO add reconnect
    jug.on "reconnect", () ->
      log "Reconnecting"
    */
  });
}).call(this);
