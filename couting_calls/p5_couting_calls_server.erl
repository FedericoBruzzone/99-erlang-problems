-module(p5_couting_calls_server).

-export([start/0,
         d1/0,
         d2/1,
         d1_rpc/1,
         d2_rpc/2,
         tot/0]).

start() ->
  io:format("*** START"),
  MaybePidServer = whereis(cc_server),
  case MaybePidServer of
    undefined ->
      PidServer = spawn(fun() -> loop() end),
      register(cc_server, PidServer);
    _ ->
      stop(), start()
  end.

stop() ->
  exit(whereis(cc_server), kill),
  unregister(cc_server),
  io:format("*** STOP").

loop() ->
  io:format("*** LOOP started"),
  receive
    {From, {d1}} ->
      put(d1, get(d1) + 1),
      d1(),
      From ! {cc_server, ok},
      loop();
    {From, {d2, X}} ->
      put(d2, get(d2) + 1),
      d2(X),
      From ! {cc_server, ok},
      loop()
  end.

d1() -> io:format("*** d1~n").
d2(X) -> io:format("*** d2 with X := ~p~n", [X]).
d1_rpc(From) -> io:format("*** d1~n"), rpc(From, {d1}).
d2_rpc(From, X) -> io:format("*** d2 with X := ~p~n", [X]), rpc(From, {d2, X}).
rpc(From, M) -> cc_server ! {From, M}.

tot() ->
  io:format("*** d1 := ~p~n", [get(d1)]),
  io:format("*** d2 := ~p~n", [get(d2)]).

