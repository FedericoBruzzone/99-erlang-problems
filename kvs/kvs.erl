% T1 ==> erl -sname t1
% T1 ==> kvs:start().
%
% T2 ==> erl -sname t2
% T2 ==> rpc:call(t1@federicobruzzone, kvs, store, [weather, sunny]).
% T2 ==> rpc:call(t1@federicobruzzone, kvs, lookup, [weather]).
%
% T1 ==> kvs:lookup(weather).

-module(kvs).
-export([start/0, store/2, lookup/1]).

start() ->
  register(kvs_pid, spawn(fun() -> loop() end)).

store(Key, Value) -> rpc({store, Key, Value}).
lookup(Key) -> rpc({lookup, Key}).

rpc(E) ->
  kvs_pid ! {self(),E},
  receive
    {kvs_pid, Reply} -> Reply
  end.

loop() ->
  receive
    {From, {store, Key, Value}} ->
      put(Key, Value),
      From ! {kvs_pid, true},
      loop();
    {From, {lookup, Key}} ->
      Value = get(Key),
      From ! {kvs_pid, Value},
      loop()
  end.

