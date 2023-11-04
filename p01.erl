% (*) Find the last element of a list.

-module(p01).

-export([last/1, start/0]).

last([H]) ->
  H;
last([_ | T]) ->
  last(T).

start() ->
  io:format("~p~n", [last([a, b, c, d])]).
