-module(dkvs_server).

-export([
         start/0, 
         stop/0, 
         store/3,
         lookup/2
        ]).

start() ->
  MaybeDkvsServerPid = whereis(dkvs_s),
  case MaybeDkvsServerPid of
    undefined ->
      DkvsServerPid = spawn(fun() -> loop() end),
      register(dkvs_s, DkvsServerPid),
      io:format("*** LOG: The server ~p started at ~p on the node ~p~n",
                [dkvs_s, DkvsServerPid, node()]);
    _ -> stop(), start()
  end.

stop() ->
  exit(whereis(dkvs_s), stop),
  unregister(dkvs_s),
  io:format("*** LOG: Stop~n").

store(From, K, V) -> rpc(From, {store, K, V}).
lookup(From, K) -> rpc(From, {lookup, K}).
rpc(From, M) -> dkvs_s ! {From, M}.

loop() ->
  io:format("*** LOG: Loop~n"),
  receive
    {From, {store, K, V}} -> 
      io:format("*** LOG: (~p, ~p) has been stored~n", [K, V]),
      From ! {self(), {node(), store_call}},
      loop();
    {From, {lookup, K}} -> 
      io:format("*** LOG: (~p) has been looked up~n", [K]),
      From ! {self(), {node(), lookup_call}},
      loop();
    Any -> io:format("*** LOG: Error, I got a message ~p~n", [Any])
  end.
