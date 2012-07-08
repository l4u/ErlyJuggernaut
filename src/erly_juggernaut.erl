-module(erly_juggernaut).
-behaviour(application).
-export([start/0, start/2, stop/1, config/1]).


config(Key) ->
    case application:get_env(erly_juggernaut, Key) of
        undefined -> erlang:error({missing_config, Key});
        {ok, Val} -> Val
    end.

start() ->
	application:start(crypto),
	application:start(public_key),
	application:start(ssl),
  application:start(gproc),
	application:start(cowboy),
	application:start(erly_juggernaut),
  erly_juggernaut_eredis_pubsub:eredis_init().

start(_Type, _Args) ->
	Dispatch = [
		{'_', [
      {[<<"static">>, '...'], cowboy_http_static, [
          {directory, <<"client_example">>},
          {mimetypes, [
              {<<".html">>, [<<"text/html">>]},
              {<<".css">>, [<<"text/css">>]},
              {<<".js">>, [<<"application/javascript">>]},
              {<<".jpg">>, [<<"image/jpeg">>]}
            ]}
        ]},
			{[<<"websocket">>], websocket_handler, []},
			{'_', default_handler, []}
		]}
	],
	cowboy:start_listener(my_http_listener, 100,
    cowboy_tcp_transport, [{port, config(http_port)}],
		cowboy_http_protocol, [{dispatch, Dispatch}]
	),
	cowboy:start_listener(my_https_listener, 100,
		cowboy_ssl_transport, [
			{port, 8443}, {certfile, "priv/ssl/cert.pem"},
			{keyfile, "priv/ssl/key.pem"}, {password, "cowboy"}],
		cowboy_http_protocol, [{dispatch, Dispatch}]
	),
	erly_juggernaut_sup:start_link().

stop(_State) ->
	ok.
