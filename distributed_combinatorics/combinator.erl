-module(combinator).

-export([start/2]).

start(N, M) ->
  Master = spawn(fun() -> create_slaves(0, N, M, []) end),
  register(master, Master), 
  timer:sleep(5000).

create_slaves(N, N, M, L) ->
  master_loop(L, 1, trunc(math:pow(N, M)));
create_slaves(X, N, M, L) ->
  Slave = spawn(fun() -> generator:create_slave(X, N, M) end),
  create_slaves(X + 1, N, M, [{X, Slave} | L]).

master_loop(_, T, T) -> master_loop_end;
master_loop(L, I, T) ->
  lists:foreach(fun({X, Slave}) -> 
                  Slave ! {perm, self(), I},
                  receive
                    {perm_res, I, Res} -> 
                      io:format("~p ", [Res])
                  end
                end, L),
  io:format("~n"),
  master_loop(L, I + 1, T).

