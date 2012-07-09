class ErlyJuggernaut
  constructor: (@options) ->
    @options || = {} 
    @options.host || = window.location.hostname
    @options.port || = 8081

    @handlers = {}
    @meta = @options.meta

    @disconnect_count = 0
    @initialized = false

    @bullet = $.bullet("ws://#{@options.host}:#{@options.port}/websocket")
    # TODO configureable path
    # TODO configureable protocol
    
    @bullet.onopen = @onconnect
    #@bullet.onclose = @ondisconnect
    @bullet.ondisconnect = @ondisconnect
    @bullet.onmessage = @onmessage
    @bullet.onheartbeat = =>
      @bullet.send "ping"
  
  trigger: (name, args...) =>
    callbacks = @handlers[name]
    if (!callbacks) 
      return
    for callback in callbacks
      callback args...

  onconnect:  () => 
    # TODO store session id? ref juggernaut/application.js line 3310
    @disconnect_count = 0
    if @initialized == false
      @initialized = true
      @trigger("connect")
    else
      # TODO trigger reconnected?
      @trigger("connect")

  ondisconnect:  () => 
    if @disconnect_count == 0
      @disconnect_count++
      @trigger("disconnect")

  onmessage: (data) =>
    message = JSON.parse(data.data)
    #@trigger "message", message
    @trigger "data", message.channel, message.data
    @trigger "#{message.channel}:data", message.data

  on: (name, callback) => 
    if ( !name || !callback ) 
      return
    if ( !@handlers[name] ) 
      @handlers[name] = []
    @handlers[name].push callback
  
  #bind: 
  unbind: (name) =>
    if (!@handlers) 
      return
    delete @handlers[name]

  write: (message) =>
    @bullet.send(JSON.stringify(message))

  subscribe: (channel, callback) =>
    if (!channel) 
      throw "Must provide a channel"
    @on("#{channel}:data", callback)
    message = {
      type: "subscribe"
      channel: channel
    }
    @write message

window.ErlyJuggernaut = ErlyJuggernaut 

