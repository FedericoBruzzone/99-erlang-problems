-module(generator).

-export([start/3]).

start(X, M, Max) ->
  io:format("*** LOG: Start with ~p ~p ~p~n", [X, M, Max]),
  L = create_list(Max,
                  lists:seq(1, M),
                  lists:seq(1, M),
                  trunc(math:pow(M, X)),
                  []),
  loop(X, L).

loop(_, []) -> end_list;
loop(X, [H | T]) -> 
  receive
    {get_next, E, Master} -> Master ! {res, E, H, X}; 
    Any -> io:format("*** LOG Gen: Error with ~p~n", [Any]) 
  end,
  loop(X, T).

create_list(0, _, _, _, Acc) ->
  Acc;
create_list(Len, E, [], R, Acc) ->
  create_list(Len, E, E, R, Acc);
create_list(Len, E, [Elem | T], R, Acc) ->
  create_list(Len - R, E, T, R, Acc ++ lists:duplicate(R, Elem)).

