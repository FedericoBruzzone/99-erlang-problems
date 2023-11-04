% (**) Flatten a nested list structure.

-module(p07).

-export([flatten/1, start/0]).

flatten(L) ->
  lists:reverse(flatten(L, [])).

flatten([], Acc) ->
  Acc;
flatten([H | T], Acc) when is_list(H) ->
  flatten(T, flatten(H, Acc));
flatten([H | T], Acc) ->
  flatten(T, [H | Acc]).

start() ->
  io:format("~p~n", [flatten([1, 2, [3, [4, [5, 6]]]])]).
