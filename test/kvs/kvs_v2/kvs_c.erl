-module(kvs_c).

-export([store_list/1, store/2, lookup/1]).

-define(SERVER, kvs_s).
-define(NODE, 't1@federicobruzzone').

store(K, V) -> send_via_rpc(store, [self(), K, V]).
lookup(K) -> send_via_rpc(lookup, [self(), K]).

% lists:foreach(fun({K, V}) -> store(K, V) end, L).
store_list(L) -> [store(K, V) || {K, V} <- L].

send_via_rpc(F, Args) ->
  rpc:call(?NODE, ?SERVER, F, Args),
  receive
    {kvs_s, R} ->
      R
  end.

