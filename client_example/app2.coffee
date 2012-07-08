$(document).ready ->
  logElement = $("#log")
  logElement.value = ""
  log = (data) =>
    logElement.val(logElement.val() + data + "\n")

  log("Subscribing to channel2")

  jug = new ErlyJuggernaut()

  jug.on "connect", () ->
    log "Connected"
    # subscribe has to be put in the callback of connect because bufferring is not supported
    jug.subscribe "channel2", (data) ->
      log "Got data: #{data}"

  jug.on "disconnect", () ->
    log "Disconnected"

  ### TODO add reconnect
  jug.on "reconnect", () ->
    log "Reconnecting"
  ###

