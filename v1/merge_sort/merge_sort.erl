-module(merge_sort).

-export([start/0]).

start() ->
  L1 = [1,2,3,4,10,8,6,7],
  L2 = [5,1,2,3,4,9,8,7,6],
  sort(L2).
  
sort(L) ->
  handle_case(L, length(L), self(), split_list(L)),
  receive
    {_, Res} -> Res % io:format("~p~n", [Res]), 
  end.

handle_case(L, 1, From, _) -> 
  From ! {self(), L};
handle_case(L, 2, From, _) -> 
  case hd(L) < hd(tl(L)) of
    true -> From ! {self(), L};
    false -> From ! {self(), lists:reverse(L)}
  end;
handle_case(_, _, From, {LL, RL}) -> 
  Self = self(),
  Left = spawn(fun() -> handle_case(LL, length(LL), Self, split_list(LL)) end),
  Right = spawn(fun() -> handle_case(RL, length(RL), Self, split_list(RL)) end), 
  From ! {self(), handle_receive(Left, Right, [])}.

handle_receive(end_l, end_r, Acc) ->
  merge_list(hd(Acc), hd(tl(Acc)));
handle_receive(Left, Right, Acc) -> 
  receive
    {Left, L} -> handle_receive(end_l, Right, [L | Acc]);
    {Right, L} -> handle_receive(Left, end_r, [L | Acc])
  end.
   
merge_list([], []) -> [];
merge_list(L1, []) -> L1;
merge_list([], L2) -> L2;
merge_list([H1 | T1] = L1, [H2 | T2] = L2) ->
  case H1 =< H2 of
    true -> [H1 | merge_list(T1, L2)];
    false -> [H2 | merge_list(L1, T2)]
  end.

split_list(L) -> 
  Len = length(L) - (length(L) div 2),
  {lists:sublist(L, 1, Len), 
   lists:sublist(L, Len + 1, length(L))}.

