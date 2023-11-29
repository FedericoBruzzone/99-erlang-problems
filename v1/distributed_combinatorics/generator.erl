-module(generator).

-export([create_slave/3]).

create_slave(X, N, M) ->
  L = create_list(trunc(math:pow(M, N)),
                  lists:seq(1, M),
                  lists:seq(1, M),
                  trunc(math:pow(M, X)),
                  []),
  slave_loop(L).


slave_loop([]) -> slave_loop_end;
slave_loop([H | T]) ->
  receive
    {perm, From, I} -> From ! {perm_res, I, H} 
  end, 
  slave_loop(T).

create_list(0, _, _, _, Acc) ->
  Acc;
create_list(Len, E, [], R, Acc) ->
  create_list(Len, E, E, R, Acc);
create_list(Len, E, [Elem | T], R, Acc) ->
  create_list(Len - R, E, T, R, Acc ++ lists:duplicate(R, Elem)).
