-module(master).

-export([start/1]).

start(N) ->
  privatestart(whereis(master), N).

privatestart(undefined, N) ->
  MasterPid =
    spawn(fun() ->
             process_flag(trap_exit, true),
             create_slaves(1, N + 1, [])
          end),
  register(master, MasterPid),
  io:format("*** LOG[start]: Master ~p is running with pid ~p at ~p~n",
            [master, MasterPid, node()]);
privatestart(_, N) ->
  stop(),
  start(N).

stop() ->
  io:format("*** LOG[stop]: Stop master~n"),
  exit(whereis(master), stop),
  unregister(master).

create_slaves(T, T, L) ->
  io:format("*** LOG[create_slaves]: All slaves have been created~n"),
  master_loop(L);
create_slaves(F, T, L) ->
  SlavePid = spawn_link(fun() -> slave_loop(F) end),
  io:format("*** LOG[create_slaves]: Slave ~p is running with pid ~p~n", [F, SlavePid]),
  Lup = [{F, SlavePid} | L],
  create_slaves(F + 1, T, Lup).

long_reverse_string(From, S) ->
  rpc({lrs, From, S}).

rpc(M) ->
  master ! M.

master_loop(L) ->
  Llen = erlang:length(L),
  % io:format("*** The length of L is ~p~n", [Llen]),
  receive
    {'EXIT', Pid, Reason} ->
      N = Reason,
      NewSlave = spawn(fun() -> slave_loop(N) end),
      Lup = [{N, NewSlave} | lists:filter(fun({_, SPid}) -> Pid =/= SPid end, L)],
      master_loop(Lup);
    {lrs, From, S} ->
      Slen = erlang:length(S),
      case Slen < Llen * 100 of
        true ->
          From
          ! {error,
             whereis(master),
             io_lib:format("The string must be larger than ~p", [Llen * 100])};
        false ->
          Ls = lists:zip(split_string(S, Slen / Llen, Slen rem Llen), lists:seq(1, Llen)),
          lists:foreach(fun({S, N}) -> lists:nth(L, N) ! {rev, S, N} end, Ls)
      end,
      master_loop(L);
    {res_rev, S, N} ->
      ok;
    Any ->
      io:format("*** LOG[master]: Error, I got ~p~n", [Any])
  end.

split_string("", _, _) ->
  [];
split_string(S, Toff, 0) ->
  Sup = lists:sublist(S, Toff + 1, erlang:length(S)),
  [lists:sublist(S, 1, Toff) | split_string(Sup, Toff, 0)];
split_string(S, Toff, N) ->
  Off = Toff + 1,
  Sup = lists:sublist(S, Off + 1, erlang:length(S)),
  [lists:sublist(S, 1, Off) | split_string(Sup, Toff, N - 1)].

slave_loop(F) ->
  receive
    {rev, S, N} ->
      io:format("*** LOG[slave ~p]: Received list [~p] number ~p to reverse~n", [F, S, N]),
      master ! {res_rev, lists:reverse(S), N},
      slave_loop(F);
    Any ->
      io:format("*** LOG[slave ~p]: Error, I got ~p~n", [F, Any]),
      slave_loop(F)
  end.
