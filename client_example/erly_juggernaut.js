(function() {
  var ErlyJuggernaut;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __slice = Array.prototype.slice;
  ErlyJuggernaut = (function() {
    function ErlyJuggernaut(options) {
      var _base, _base2;
      this.options = options;
      this.subscribe = __bind(this.subscribe, this);
      this.write = __bind(this.write, this);
      this.unbind = __bind(this.unbind, this);
      this.on = __bind(this.on, this);
      this.onmessage = __bind(this.onmessage, this);
      this.ondisconnect = __bind(this.ondisconnect, this);
      this.onconnect = __bind(this.onconnect, this);
      this.trigger = __bind(this.trigger, this);
      this.options || (this.options = {});
      (_base = this.options).host || (_base.host = window.location.hostname);
      (_base2 = this.options).port || (_base2.port = 8081);
      this.handlers = {};
      this.meta = this.options.meta;
      this.disconnect_count = 0;
      this.bullet = $.bullet("ws://" + this.options.host + ":" + this.options.port + "/websocket");
      this.bullet.onopen = this.onconnect;
      this.bullet.ondisconnect = this.ondisconnect;
      this.bullet.onmessage = this.onmessage;
      this.bullet.onheartbeat = __bind(function() {
        return this.bullet.send("ping");
      }, this);
    }
    ErlyJuggernaut.prototype.trigger = function() {
      var args, callback, callbacks, name, _i, _len, _results;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      callbacks = this.handlers[name];
      if (!callbacks) {
        return;
      }
      _results = [];
      for (_i = 0, _len = callbacks.length; _i < _len; _i++) {
        callback = callbacks[_i];
        _results.push(callback.apply(null, args));
      }
      return _results;
    };
    ErlyJuggernaut.prototype.onconnect = function() {
      this.disconnect_count = 0;
      return this.trigger("connect");
    };
    ErlyJuggernaut.prototype.ondisconnect = function() {
      if (this.disconnect_count === 0) {
        this.disconnect_count++;
        return this.trigger("disconnect");
      }
    };
    ErlyJuggernaut.prototype.onmessage = function(data) {
      var message;
      message = JSON.parse(data.data);
      this.trigger("data", message.channel, message.data);
      return this.trigger("" + message.channel + ":data", message.data);
    };
    ErlyJuggernaut.prototype.on = function(name, callback) {
      if (!name || !callback) {
        return;
      }
      if (!this.handlers[name]) {
        this.handlers[name] = [];
      }
      return this.handlers[name].push(callback);
    };
    ErlyJuggernaut.prototype.unbind = function(name) {
      if (!this.handlers) {
        return;
      }
      return delete this.handlers[name];
    };
    ErlyJuggernaut.prototype.write = function(message) {
      return this.bullet.send(JSON.stringify(message));
    };
    ErlyJuggernaut.prototype.subscribe = function(channel, callback) {
      var message;
      if (!channel) {
        throw "Must provide a channel";
      }
      this.on("" + channel + ":data", callback);
      message = {
        type: "subscribe",
        channel: channel
      };
      return this.write(message);
    };
    return ErlyJuggernaut;
  })();
  window.ErlyJuggernaut = ErlyJuggernaut;
}).call(this);
