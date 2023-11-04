% (*) Find the Kth element of a list.

-module(p03).

-export([kth/2, start/0]).

kth([H | _], 0) ->
  H;
kth([_ | T], K) ->
  kth(T, K - 1).

start() ->
  io:format("~p~n", [kth([a, b, c, d], 2)]).
