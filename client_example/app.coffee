$(document).ready ->
  logElement = $("#log")
  logElement.value = ""
  log = (data) =>
    logElement.val(logElement.val() + data + "\n")

  log("Subscribing to channel1")

  jug = new ErlyJuggernaut()

  jug.on "connect", () ->
    log "Connected"
    # subscribe has to be put in the callback of connect because bufferring is not supported
    jug.subscribe "channel1", (data) ->
      log "Got data: #{data}"

  jug.on "disconnect", () ->
    jug.unbind "channel1:data"
    log "Disconnected"

  ### TODO add reconnect
  jug.on "reconnect", () ->
    log "Reconnecting"
  ###

