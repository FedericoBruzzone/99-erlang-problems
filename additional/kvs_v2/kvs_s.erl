% kvs server

-module(kvs_s).

-export([start/0, stop/0, store/3, lookup/2]).

start() ->
  PidServer = spawn(fun() -> loop() end),
  register(kvs_s, PidServer).

stop() ->
  unregister(kvs_s),
  exit(whereis(kvs_s), kill).

loop() ->
  receive
    {From, {store, K, V}} ->
      put(K, V),
      From ! {kvs_s, true},
      loop();
    {From, {lookup, K}} ->
      V = get(K),
      From ! {kvs_s, V},
      loop()
  end.

store(From, K, V) ->
  rpc(From, {store, K, V}).

lookup(From, K) ->
  rpc(From, {lookup, K}).

rpc(From, M) -> kvs_s ! {From, M}.
% receive
%   {kvs_s, R} ->
%     R
% end.
