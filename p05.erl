% (*) Reverse a list.

-module(p05).

-export([reverse/1, start/0]).

% Not tail recursive
%
% reverse([]) ->
%   [];
% reverse([H | T]) ->
%   reverse(T) ++ [H].

% Tail recursive
reverse(L) ->
  reverse(L, []).

reverse([], Acc) ->
  Acc;
reverse([H | T], Acc) ->
  reverse(T, [H | Acc]).

start() ->
  io:format("~p~n", [reverse([1, 2, 3, 4, 5])]).
