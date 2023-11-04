% (*) Find the number of elements of a list.

-module(p04).

-export([len/1, start/0]).

len([]) ->
  0;
len([_ | T]) ->
  1 + len(T).

start() ->
  io:format("~p~n", [len([a, b, c, d, e, f, g, h, i, j])]).
