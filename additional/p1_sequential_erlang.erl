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

is_an_anagram(_, []) -> false;
is_an_anagram(Str, [H|T]) ->
  lists:sort(Str) == lists:sort(H) orelse
  is_an_anagram(Str, T).

factors(I) ->
  factors(I, 2, []).

factors(1, _, Acc) ->
  Acc;
factors(I, F, Acc) when I rem F =:= 0 ->
  factors(I div F, F, [F|Acc]);
factors(I, F, Acc) ->
  factors(I, F+1, Acc).

is_proper(I) ->
  I == sum_proper_divisors(I).

sum_proper_divisors(I) ->
  sum_proper_divisors(I, 1, 0).

sum_proper_divisors(I, I, Acc) ->
  Acc;
sum_proper_divisors(I, F, Acc) when I rem F =:= 0 ->
  sum_proper_divisors(I, F+1, Acc+F);
sum_proper_divisors(I, F, Acc) ->
  sum_proper_divisors(I, F+1, Acc).


start() ->
  io:format("~p~n", [is_palindrome("abba")]),
  io:format("~p~n", [is_palindrome("poi")]),
  io:format("~p~n", [is_an_anagram("abc", ["def", "ghi", "cba"])]),
  io:format("~p~n", [factors(30)]),
  io:format("~p~n", [is_proper(28)]),
  io:format("~p~n", [is_proper(6)]).

