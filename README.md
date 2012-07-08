# ErlyJuggernaut

ErlyJuggernaut is an implementation of [juggernaut](http://github.com/maccman/juggernaut) in erlang. 

ErlyJuggernaut's API is similar to that of the original implementation, it is partly compatible to juggernaut's client. As the development of socket.io-erlang became suspended, socket.io isn't used.

This project starts at [spawnfest 2012](http://spawnfest.com), where I learnt a lot about Erlang from #erlounge.

## Libraries used

Instead of node.js and socket.io, erlyJuggernaut uses:

* [cowboy](http://github.com/extend/cowboy) for socket server, substituting node.js 
* [bullet](http://github.com/extend/bullet) for client-side abstraction to websocket and fallback transports, substituting socket.io

### Other libraries used:

* [gproc](http://github.com/uwiger/gproc)
* [eredis](http://github.com/wooga/eredis)
* [jsx](http://github.com/talentdeficit/jsx)

## Installation

Make sure erlang and redis is installed.

Start Redis:

`redis-server`

Compile and start ErlyJuggernaut:

```
make
./start.sh
```

### Publishing Data from Ruby

Install juggernaut ruby gem

`gem install juggernaut`

Publish some data

```
$ irb
require "juggernaut"
Juggernaut.publish("channel1", "Some data")

Juggernaut.publish(["channel1", "channel2"], ["foo", "bar"])
```

For publishing from other clients, please refer to the [juggernaut page](http://github.com/maccman/juggernaut)

