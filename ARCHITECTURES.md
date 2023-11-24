
# Server and Ring
```erlang
start(N) ->
  register(server, self()),
  First = spawn(fun() -> create_ring(1, N) end), % if start from 0 N must be N - 1
  register(first, First),
  receive
    ring_created -> server_loop(First)
  end.

create_ring(N, N) ->
  Next = whereis(first),
  server ! ring_created,
  node_loop(N, Next);
create_ring(X, N) ->
  Next = spawn_link(fun() -> create_ring(X + 1, N) end),
  node_loop(X, Next).

server_loop(_) -> ok.
node_loop(_, _) -> ok.
```

# Master and Slaves
```erlang
start(N) ->
  MaybeMasterPid = whereis(master),
  case MaybeMasterPid of
    undefined -> Master =
      spawn(fun() ->
              process_flag(trap_exit, true),
              create_slaves(1, N + 1, [])
            end),
      register(master, Master);
    _ -> stop(), start(N)
  end.

stop() -> unregister(master), exit(whereis(master), stop).

create_slaves(T, T, L) ->
  master_loop(L);
create_slaves(F, T, L) ->
  SlavePid = spawn_link(fun() -> slave_loop(F) end),
  Lup = [{F, SlavePid} | L],
  create_slaves(F + 1, T, Lup).

master_loop(_) -> ok.
slave_loop(_) -> ok.
```

# Bowtie
```erlang
start(N) ->
  FirstLine = lists:map(fun(X) ->
                          {X, spawn(fun() -> loop_first(X) end)}
                        end,
                        lists:map(fun(X) ->
                                      list_to_atom(lists:concat(["fl", X]))
                                  end,
                                  lists:seq(1, N))),
  SecondLine = lists:map(fun(X) ->
                           {X, spawn(fun() -> loop_second(X, FirstLine) end)}
                         end,
                         lists:map(fun(X) ->
                                     list_to_atom(lists:concat(["sl", X]))
                                   end,
                                   lists:seq(1, N))),
  lists:foreach(fun({T, Pid}) -> register(T, Pid) end, SecondLine).

loop_first(_) -> ok.
loop_second(_, _) -> ok.
```

