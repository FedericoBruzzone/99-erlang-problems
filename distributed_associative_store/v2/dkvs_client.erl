-module(dkvs_client).

-export([start/1, store/2, lookup/1]).

-define(MODULE_SERVER, dkvs_server).

start(N) ->
  L = lists:map(fun(X) ->
                  Node = lists:concat(["n", X, "@federicobruzzone"]),
                  NodeAtom = list_to_atom(Node),
                  rpc:call(NodeAtom, ?MODULE_SERVER, start, []),
                  NodeAtom
                end, lists:seq(1, N)),
  put(l, L).

store(K, V) ->
  S = self(),
  L = get(l),
  lists:foreach(fun(X) ->
                  rpc:call(X, ?MODULE_SERVER, store, [S, K, V]),
                  receive
                    {ServerPid, Node, store_call} ->
                      io:format("*** LOG: (~p, ~p) has been stored at ~p with pid ~p~n", [K, V, Node, ServerPid]);
                    Any -> io:format("*** LOG: Error, received ~p~n", [Any])
                  end
                end, L).

lookup(K) ->
  S = self(),
  RNode = get_random_node(),
  io:format("*** LOG: RNode ~p~n", [RNode]),
  rpc:call(RNode, ?MODULE_SERVER, lookup, [S, K]),
  receive
    {ServerPid, Node, lookup_call} ->
      io:format("*** LOG: (~p) has been looked up at ~p with pid ~p~n", [K, Node, ServerPid]);
    Any -> io:format("*** LOG: Error, received ~p~n", [Any])
  end.

get_random_node() ->
  L = get(l),
  io:format("*** LOG: L ~p~n", [L]),
  lists:nth(1, L).
