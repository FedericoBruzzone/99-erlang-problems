-module(server).

-export([start/0,
        is_palindrome/3]).

-define(MM1_NODE, mm1@federicobruzzone).
-define(MM2_NODE, mm2@federicobruzzone).

start() ->
  group_leader(whereis(user), self()),
  io:format("Starting server~n"),
  Pserver = spawn(fun() -> loop(0, "") end),
  register(server, Pserver),
  Pserver.

is_palindrome(N, S, Node) -> rpc({is_palindrome, N, S, Node}).
rpc(M) -> server ! M.

loop(N, First) ->
  receive
    {is_palindrome, NMM1, S, ?MM1_NODE} when First =:= "",
                                             N =:= NMM1 ->
      loop(N + 1, S);
    {is_palindrome, NMM2, S, ?MM2_NODE} when First =/= "",
                                             N - 1 =:= NMM2 ->
      io:format("Is palindrome ~p~n", [S =:= First]),
      loop(N, "")
  end.
