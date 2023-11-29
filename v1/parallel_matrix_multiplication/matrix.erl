-module(matrix).

-export([mproduct/2]).

% matrix:mproduct([[1,1,2], [0,1,-3]], [[1,2,0],[1,5,-2],[1,1,1]]).

mproduct(A, B) -> 
  Head = spawn(fun() -> head_loop(A, B) end),
  register(head, Head).

head_loop(A, B) -> 
  LenA = length(A), LenB = length(B), 
  Tail = spawn(fun() -> tail_loop(whereis(head), 1, LenA + 1, 1, LenB + 1, [], []) end),
  BColList = lists:map(fun({I, Col}) -> 
                           {I, spawn(fun() -> b_col_loop(I, Col, Tail) end)}
                       end, lists:zip(lists:seq(1, LenB), B)),
  _ = lists:map(fun({I, Row}) -> 
                           {I, spawn(fun() -> a_row_loop(I, Row, BColList) end)}
                       end, lists:zip(lists:seq(1, LenA), A)),
  receive
    {c_matrix, C} -> 
      io:format("~p~n", [C]);
    Any -> Any
  end.

a_row_loop(I_R, L_R, BColList) ->
  Pids = lists:map(fun({_, X}) -> X end, BColList),
  lists:foreach(fun(X) -> X ! {row, I_R, L_R} end, Pids).

b_col_loop(I_C, L_C, Tail) -> 
  receive
    {row, I_R, L_R} -> 
      ValRC = calc_valrc(L_R, L_C),
      Tail ! {valrc, I_R, I_C, ValRC}
  end,
  b_col_loop(I_C, L_C, Tail).

tail_loop(HeadPid, LenA, LenA, _, _, _, C) ->
  HeadPid ! {c_matrix, lists:reverse(C)};
tail_loop(HeadPid, I, LenA, LenB, LenB, Curr, C) ->
  tail_loop(HeadPid, I + 1, LenA, 1, LenB, [], [lists:reverse(Curr)|C]);
tail_loop(HeadPid, I, LenA, J, LenB, Curr, C) -> 
  receive
    {valrc, I, J, ValRC} -> 
      tail_loop(HeadPid, I, LenA, J + 1, LenB, [ValRC|Curr], C) 
  end.

calc_valrc(L_R, L_C) -> lists:foldl(fun(X, Sum) -> X + Sum end, 0, lists:zipwith(fun(X, Y) -> X * Y end, L_R, L_C)).

