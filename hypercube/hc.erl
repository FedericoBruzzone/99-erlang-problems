-module(hc).

-export([start/1]).

start(N) ->
  L = lists:map(fun(X) -> lists:reverse(X) end, list_of_bin(N, [])),
  LwPid = lists:map(fun(X) -> {X, spawn(fun() -> link_each_other(X) end)} end, L),
  lists:foreach(fun({X, Pid}) -> register(list_to_atom(X), Pid) end, LwPid),
  lists:foreach(fun({_, Pid}) -> Pid ! start end, LwPid),
  io:format("LwPid: ~p~n", [LwPid]),
  timer:sleep(1000),
  {_, Pid} = hd(LwPid),
  Pid ! print.

link_each_other(X) ->
  receive
    start ->
      Ln = get_neighbours(X),
      %io:format("~p ~p ~p ~p ~p~n", [Ln, hd(Ln), X, list_to_atom(hd(Ln)), whereis(list_to_atom(hd(Ln)))]),
      lists:foreach(fun(X) -> link(whereis(list_to_atom(X))) end, Ln), 
      loop_node(X, Ln);
    Any ->
      io:format("X: ~p, Any: ~p~n", [X, Any]),
      link_each_other(X)
  end.

loop_node(X, Ln) -> 
  receive 
    print -> 
      io:format("~p~n", [X]),
      lists:foreach(fun(Y) -> whereis(list_to_atom(Y)) ! print end, Ln),
      loop_node(X, Ln)
    after 1000 -> true 
  end.

list_of_bin(0, Acc) ->
  [Acc];
list_of_bin(N, Acc) ->
  list_of_bin(N-1, [0 | Acc]) ++ list_of_bin(N-1, [1 | Acc]).

get_neighbours(X) ->
  N = length(X),
  lists:map(fun(Y) -> flip(X, Y) end , lists:seq(1, N)).

flip(X, Y) ->
  lists:sublist(X, 1, Y - 1) ++ 
  flip_bit(lists:nth(Y, X)) ++ 
  lists:sublist(X, Y+1, length(X)).

flip_bit(0) -> [1];
flip_bit(1) -> [0].
