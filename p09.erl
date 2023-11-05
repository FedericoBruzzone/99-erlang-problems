% (**) Pack consecutive duplicates of list elements into sublists.

-module(p09).

-export([pack/1, start/0]).

pack(L) ->
  pack(L, []).

pack([], Acc) ->
  Acc;
pack([H], Acc) ->
  [[H | Acc]];
pack([H, H | T], Acc) ->
  pack([H | T], [H | Acc]);
pack([F, S | T], Acc) ->
  [[F | Acc] | pack([S | T], [])].

start() ->
  io:format("~p~n", [pack([a, a, a, a, b, c, c, a, a, d, e, e, e, e])]).
