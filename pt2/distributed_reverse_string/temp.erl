-module(temp).

-export([split_string/2]).


split_string(S, N) ->
  Len = length(S),
  Rem = Len rem N,
  Div = trunc(Len div N),
  calc_split(S, Rem, Div, []).

calc_split("", 0, _, Acc) ->
  Acc;
calc_split(S, 0, Div, Acc) ->
  calc_split(lists:sublist(S, Div + 1, length(S)),
             0,
             Div,
             [lists:sublist(S, 1, Div) | Acc]);
calc_split(S, Rem, Div, Acc) ->
  calc_split(lists:sublist(S, Div + 1, length(S)),
             Rem - 1,
             Div,
             [lists:sublist(S, 1, Div + 1) | Acc]).





