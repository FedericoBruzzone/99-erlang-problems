# Message Passing in Distributed Erlang

**Note:** all the nodes are running on the **same** machine,
it's "locally" distributed.

**How to know the host name?**: `inet:gethostname()`

There are 3 ways for a `Client` process running on node `client@localhost` to send
a message to a `Server` process running on node `server@localhost`:

### 1. `Client` knows the PID of `Server`

The `Client` process may have spawned the `Server` process
on `server@localhost` or requested its PID.

*client.erl*

```erlang
ServerPid ! Msg
```

### 2. `Server` is locally registered

The `Server` process is registered **locally** as `server` on `server@localhost`.

*server.erl*

```erlang
register(server, ServerPid)
```

*client.erl*

```erlang
{server, server@localhost} ! Msg
```

### 3. `Server` is globally registered

The `Server` process is registered **globally** as `server` on `server@localhost`.

`global` functions work only after the two nodes are connected,
the standard way to do it is by using `net_adm:ping(Node)`.

If the `Client` spawns the `Server` there's no need to explicitly connect them.

*server.erl*

```erlang
global:register_name(server, ServerPid),
```

*client.erl*

```erlang
net_adm:ping(server@localhost). % Very important!
global:send(server, Msg)

% Alternative way
global:whereis_name(server) ! Msg
```

# Architectures

### Server and Ring
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

### Master and Slaves
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

### Bowtie
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

