% (*) Run-length encoding of a list.
%
% Use the result of problem P09 to implement the so-called run-length encoding
% data compression method. Consecutive duplicates of elements are encoded as
% tuples (N, E) where N is the number of duplicates of the element E.

-module(p10).

-export([encode/1, start/0]).

encode(L) ->
  X = pack(L),
  lists:map(fun(E) -> {length(E), hd(E)} end, X).

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
  io:format("~p~n", [encode([a, a, a, a, b, c, c, a, a, d, e, e, e, e])]).
