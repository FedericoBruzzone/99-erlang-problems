-module(tmp).
-export([start/0]).

split_string("", _, _) -> [];
split_string(S, Toff, 0) ->
  Sup = lists:sublist(S, Toff + 1, erlang:length(S)),
  [lists:sublist(S, 1, Toff) | split_string(Sup, Toff, 0)];
split_string(S, Toff, N) ->
  Off = Toff + 1,
  Sup = lists:sublist(S, Off + 1, erlang:length(S)),
  [lists:sublist(S, 1, Off) | split_string(Sup, Toff, N - 1)].

start() ->
  io:format("start~n"),
  io:format("~p~n", [split_string("0012345678901234567890123456789123456789aaa",
                                  14,
                                  1)]).
