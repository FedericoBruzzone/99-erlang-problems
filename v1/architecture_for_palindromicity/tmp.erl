-module(tmp).

-export([start/0]).


split_string(S) ->
  case length(S) rem 2 =:= 0 of
    true -> {lists:sublist(S, 1, length(S) div 2),
             lists:sublist(S, (length(S) div 2) + 1, length(S))};
    false -> {lists:sublist(S, 1, (length(S) div 2) + 1),
             lists:sublist(S, (length(S) div 2) + 1, length(S))}
  end.

start() ->
  io:format("123456 ~p~n", [split_string("123456")]),
  io:format("1234567 ~p~n", [split_string("1234567")]).
