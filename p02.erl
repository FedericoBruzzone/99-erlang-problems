% (*) Find the last but one element of a list.

-module(p02).

-export([penultimate/1, start/0]).

penultimate([X, _]) ->
  X;
penultimate([_ | T]) ->
  penultimate(T).

start() ->
  io:format("~p~n", [penultimate([1, 2, 3, 4, 5])]).
