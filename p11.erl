-module(p11).

-export([encodeModified/1, start/0]).

encodeModified(L) ->
  X = pack(L),
  lists:map(fun(E) -> 
              case length(E) of
                1 -> hd(E);
                _ -> {length(E), hd(E)} 
              end
            end, X).

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
  io:format("~p~n", [encodeModified([a, a, a, a, b, c, c, a, a, d, e, e, e, e])]).
