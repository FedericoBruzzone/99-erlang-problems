% erl -sname t1
% > c(p5_couting_calls_server).
% > p5_couting_calls_server:start().

-module(p5_couting_calls_server).

-export([start/0,
         stop/0,
         d1/1,
         d2/2,
         tot/1]).

start() ->
  MaybePidServer = whereis(cc_server),
  case MaybePidServer of
    undefined ->
      PidServer = spawn(fun() -> loop() end),
      register(cc_server, PidServer),
      io:format("*** LOG: ~p is running at: ~p~n",
                [cc_server, PidServer]);
    _ -> stop(), start()
  end.

stop() ->
  PidServer = whereis(cc_server),
  exit(PidServer, stopped),
  unregister(cc_server),
  io:format("*** LOG: ~p has been stopped, it was running at ~p~n",
            [cc_server, PidServer]).

loop() ->
  receive
    {From, {d1}} ->
      D1res = d1(), add_one_to(d1), From ! {cc_server, D1res}, loop();
    {From, {d2, X}} ->
      D2res = d2(X), add_one_to(d2), From ! {cc_server, D2res}, loop();
    {From, {tot}} ->
      Totres = tot(), add_one_to(tot), From ! {cc_server, Totres}, loop()
  end.

add_one_to(K) ->
  V = get(K),
  case V of undefined -> put(K, 1); _ -> put(K, V + 1) end.

d1() -> io:format("*** LOG: d1 has been called~n"), d1res.
d2(X) -> io:format("*** LOG: d2 has been called with X = ~p~n", [X]), d2res.
tot() ->
  io:format("*** LOG: Tot d1 = ~p~n", [get(d1)]),
  io:format("*** LOG: Tot d2 = ~p~n", [get(d2)]),
  [{d1, get(d1)}, {d2, get(d2)}, {tot, get(tot)}].

d1(From) -> rpc(From, {d1}).
d2(From, X) -> rpc(From, {d2, X}).
tot(From) -> rpc(From, {tot}).
rpc(From, M) -> cc_server ! {From, M}.

