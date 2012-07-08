-module(erly_juggernaut_eredis_pubsub).
-export([eredis_init/0]).

add_channels(Sub, Channels) ->
  ok = eredis_sub:controlling_process(Sub),
  ok = eredis_sub:subscribe(Sub, Channels),
  lists:foreach(
    fun (_C) ->
        receive M ->
            io:format("~p", [M]),
            eredis_sub:ack_message(Sub)
        end
    end, Channels).

s() ->
  Res = eredis_sub:start_link("127.0.0.1", 6379, ""),
  {ok, C} = Res,
  C.

send_data_to_channel(Channel, Data) ->
  error_logger:info_msg("send data ~p to channel ~p", [Data, Channel]),
  Key = {erlyJug, Channel},
  gproc:send({p, l, Key}, {self(), Key, Data}).

receiver(Sub) ->
  receive
    Msg -> 
      error_logger:info_msg("Msg =  ~p~n", [Msg]),
      {message, <<"juggernaut">>, Content, _} = Msg,
      case jsx:is_json(Content) of
        true ->
          Terms = jsx:decode(Content),
          Channels = proplists:get_value(<<"channels">>, Terms),
          Data = proplists:get_value(<<"data">>, Terms),
          [send_data_to_channel(Channel, Data) ||Channel <- Channels];
        false->
          error_logger:info_msg("not json")
      end,
      io:format("received ~p~n", [Msg]),
      eredis_sub:ack_message(Sub),
      receiver(Sub)
  end.

eredis_init() ->
  Sub = s(),
  spawn_link( fun () -> 
    add_channels(Sub, [<<"juggernaut">>]),
    ok = eredis_sub:controlling_process(Sub),
    receiver(Sub)
  end).
