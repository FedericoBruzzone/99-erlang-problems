-module(ms).

-export([start/1, to_slave/2]).

start(N) ->
  io:format("*** LOG[start]: Start master~n"),
  MaybeMasterPid = whereis(master),
  case MaybeMasterPid of
    undefined ->
      MasterPid =
        spawn(fun() ->
                 process_flag(trap_exit, true),
                 create_slaves(1, N + 1, [])
              end),
      register(master, MasterPid);
    _ ->
      stop(),
      start(N)
  end.

to_slave(Message, N) ->
  master ! {msg, N, Message}.

stop() ->
  io:format("*** LOG[stop]: Stop master~n"),
  unregister(master),
  exit(whereis(master), stop).

create_slaves(T, T, L) ->
  io:format("*** LOG[create_slaves]: All slaves have been created~n"),
  master_loop(L);
create_slaves(F, T, L) ->
  SlavePid = spawn_link(fun() -> slave_loop(F) end),
  Lup = [{F, SlavePid} | L],
  create_slaves(F + 1, T, Lup).

master_loop(L) ->
  io:format("*** LOG[master_loop]: Master is running at ~p with ~p slaves~n", [self(), L]),
  receive
    {msg, N, Message} ->
      [{_, Pid} | _] = lists:filter(fun({Id, _}) -> Id == N end, L),
      Pid ! Message,
      master_loop(L);
    {'EXIT', Pid, Reason} ->
      io:format("*** LOG[master_loop]: Slave ~p died with reason ~p~n", [Pid, Reason]),
      N = Reason,
      SlavePid = spawn_link(fun() -> slave_loop(N) end),
      Lup = [{N, SlavePid} | lists:filter(fun({_, Id}) -> Id /= Pid end, L)],
      master_loop(Lup);
    Any ->
      io:format("*** LOG[master_loop]: Error, we received ~p~n", [Any]),
      master_loop(L)
  end.

slave_loop(N) ->
  io:format("*** LOG[slave_loop]: Slave number ~p is running at ~p~n", [N, self()]),
  receive
    die ->
      exit(N);
    Any ->
      io:format("*** LOG[slave_loop]: Slave number ~p (pid: ~p) received ~p~n",
                [N, self(), Any]),
      slave_loop(N)
  end.
