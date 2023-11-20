-module(dkvs_client).

-export([store/2, lookup/1]).

-define(NODE1, n1@federicobruzzone).
-define(NODE2, n2@federicobruzzone).
-define(MODULE_SERVER, dkvs_server).

store(K, V) ->
  rpc:call(?NODE1, ?MODULE_SERVER, store, [self(), K, V]),
  rpc:call(?NODE2, ?MODULE_SERVER, store, [self(), K, V]),
  receive
    {SPid, {?NODE1, M}} -> io:format("*** LOG: Receive ~p from ~p~n", [M, SPid]);
    {SPid, {?NODE2, M}} -> io:format("*** LOG: Receive ~p from ~p~n", [M, SPid]);
    Any -> io:format("*** LOG: Error, received ~p~n", [Any])
  end.

lookup(K) ->
  Node = get_random_node(),
  rpc:call(Node, ?MODULE, lookup, [self(), K]),
  receive
    {SPid, {?NODE1, M}} -> io:format("*** LOG: Receive ~p from ~p~n", [M, SPid]);
    {SPid, {?NODE2, M}} -> io:format("*** LOG: Receive ~p from ~p~n", [M, SPid]);
    Any -> io:format("*** LOG: Error, received ~p~n", [Any])
  end.

get_random_node() -> ?NODE1.
