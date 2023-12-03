-module(combinator).

-export([start/2]).

start(N, M) -> 
  register(master, self()),
  Ss = create_slaves(0, N, M, []),
  io:format("*** LOG: Ring is created~n"),
  master_loop(1, trunc(math:pow(M, N)) + 1, N, Ss).

create_slaves(N, N, _, Acc) -> Acc; 
create_slaves(X, N, M, Acc) -> 
  S = spawn(fun() -> generator:start(X, M, trunc(math:pow(M, N))) end),
  io:format("*** LOG: ~p with pid ~p and N: ~p M: ~p Acc: ~p~n", [X, S, N, M, Acc]),
  create_slaves(X + 1, N, M, [S | Acc]).

master_loop(N, N, _, _) -> ok;
master_loop(E, Max, N, Ss) -> 
  lists:foreach(fun(X) -> X ! {get_next, E, self()} end, Ss),
  wait(E, 0, N),
  master_loop(E + 1, Max, N, Ss).

wait(_, N, N) -> io:format("~n");
wait(E, X, N) ->
  receive
    {res, E, H, X} -> io:format("~p ", [H])
    % Any -> io:format("*** LOG Comb: Error with ~p~n", [Any]) 
  end,
  wait(E, X + 1, N).
  
