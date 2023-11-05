% (**) Eliminate consecutive duplicates of list elements.
%
% If a list contains repeated elements they should be replaced with a single
% copy of the element. The order of the elements should not be changed.

-module(p08).

-export([compress/1, start/0]).

% ========== First way ==========
%
% compress([F, S | T]) ->
%   if F == S -> compress([S | T]);
%      true -> [F | compress([S | T])]
%   end.
%
% ========== Second way ==========
% compress([F, S | T]) when F == S ->
%   compress([S | T]);
% compress([F, S | T]) ->
%   [F | compress([S | T])].

compress([H, H | T]) ->
  compress([H | T]);
compress([F, S | T]) ->
  [F | compress([S | T])];
compress(L)-> L.

start() ->
  io:format("~p~n", [compress([a, a, a, a, b, c, c, a, a, d, e, e, e, e])]).
