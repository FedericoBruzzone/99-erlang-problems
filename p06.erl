% (*) Find out whether a list is a palindrome.

-module(p06).

-export([is_palindrome/1, start/0]).

is_palindrome(L) ->
  L == p05:reverse(L).

start() ->
  io:format("~p~n", [is_palindrome([1, 2, 3, 2, 1])]).
