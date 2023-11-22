-module(server).

-export([start/0,
        is_palindrome/3]).

-define(MM1_NODE, mm1@federicobruzzone).
-define(MM2_NODE, mm2@federicobruzzone).

start() ->
  group_leader(whereis(user), self()),
  io:format("Starting server~n"),
  Pserver = spawn(fun() -> loop("") end),
  register(server, Pserver),
  Pserver.

is_palindrome(N, S, Node) -> rpc({is_palindrome, N, S, Node}).
rpc(M) -> server ! M.

loop(TMP) ->
  receive
    {is_palindrome, _, S, ?MM1_NODE} when TMP =:= "" ->
      loop(S);
    {is_palindrome, _, S, ?MM2_NODE} when TMP =/= "" ->
      io:format("Is palindrome ~p~n", [S =:= TMP]),
      loop("");

    Any -> io:format("Received ~p~n", [Any]), loop(TMP)
  end.
