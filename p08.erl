% (**) Eliminate consecutive duplicates of list elements.

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

compress([]) ->
  [];
compress([H]) ->
  [H];
compress([H, H | T]) ->
  compress([H | T]);
compress([F, S | T]) ->
  [F | compress([S | T])].

start() ->
  io:format("~p~n", [compress([a, a, a, a, b, c, c, a, a, d, e, e, e, e])]).
