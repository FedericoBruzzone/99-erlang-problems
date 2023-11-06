-module(p1_sequential_erlang).

-export([start/0]).

is_palindrome(Str) ->
  Str =:= reverse(Str). % lists:reverse(Str)

reverse(Str) ->
  reverse(Str, []).
reverse([], Acc) ->
  Acc;
reverse([H|T], Acc) ->
  reverse(T, [H|Acc]).

start() ->
  io:format("~p~n", [is_palindrome("abba")]),
  io:format("~p~n", [is_palindrome("poi")]).
