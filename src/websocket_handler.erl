-module(websocket_handler).
-behaviour(cowboy_http_handler).
-behaviour(cowboy_http_websocket_handler).
-export([init/3, handle/2, terminate/2]).
-export([websocket_init/3, websocket_handle/3,
	websocket_info/3, websocket_terminate/3]).
-export([client_message_handler/2]).

init({_Any, http}, Req, []) ->
	case cowboy_http_req:header('Upgrade', Req) of
		{undefined, Req2} -> {ok, Req2, undefined};
		{<<"websocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket};
		{<<"WebSocket">>, _Req2} -> {upgrade, protocol, cowboy_http_websocket}
	end.

handle(Req, State) ->
	{ok, Req2} = cowboy_http_req:reply(200, [{'Content-Type', <<"text/html">>}], <<"ErlyJuggernaut">>, Req),
	{ok, Req2, State}.

terminate(_Req, _State) ->
  %error_logger:info_msg("~p", [State]),
	ok.


websocket_init(_Any, Req, []) ->
  %eredis_init(),
	Req2 = cowboy_http_req:compact(Req),
	{ok, Req2, undefined, hibernate}.

websocket_handle({text, Msg}, Req, State) ->
  case jsx:is_json(Msg) of
    true ->
      Terms = jsx:decode(Msg),
      Type = proplists:get_value(<<"type">>, Terms),
      client_message_handler(Type, Terms),
      error_logger:info_msg("received msg ~p", [Terms]);
    false ->
      error_logger:info_msg("not json")
  end,

	%%{reply, {text, << "You said: ", Msg/binary >>}, Req, State, hibernate};
	{ok, Req, State};
websocket_handle(_Any, Req, State) ->
	{ok, Req, State}.

websocket_info(Info, Req, State) ->
  case Info of
    {_PID,{erlyJug, Channel}, Msg} ->
      error_logger:info_msg("broadcast msg ~p to channel  ~p~n", [Msg, Channel]),
      Json = jsx:encode([{<<"data">>, Msg}, {<<"channel">>, Channel}]),
      {reply, {text, Json}, Req, State, hibernate};
    _ -> 
      {ok, Req, State, hibernate}
  end.

websocket_terminate(_Reason, _Req, _State) ->
  % TODO gproc and eredis terminate, not necessary?
  % gproc:unreg({p, l, ?WSKey}),
  % error_logger:info_msg("stop redis"),
  % eredis_sub:stop(s()),
	ok.


client_message_handler(Type, Terms) ->
  case Type of 
    <<"subscribe">> -> 
      Channel = proplists:get_value(<<"channel">>, Terms),
      error_logger:info_msg("subscribe channel ~p", [Channel]),
      Key = {erlyJug, Channel},
      gproc:reg({p, l, Key});
    _ ->
      error_logger:info_msg("Unknown Type in client message")
  end.

