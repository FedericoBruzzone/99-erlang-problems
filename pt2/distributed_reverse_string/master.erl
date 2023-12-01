-module(master).

-export([start/0, long_reverse_string/1]).

start() ->
  Master = spawn(fun() ->
                   process_flag(trap_exit, true),
                   master_loop()
                 end),
  register(master, Master).

master_loop() ->
  io:format("*** LOG: master_loop with pid ~p~n", [self()]),
  receive
    {reverse_string, S, N} ->
      Slaves = create_slaves(1, N + 1),
      SplitSList = split_string(S, N),
      io:format("*** LOG: The slaves are ~p~n", [Slaves]),
      io:format("*** LOG: String splitted in ~p parts: ~p~n", [N, SplitSList]),
      ZippedList = lists:zip(Slaves, SplitSList),
      Res =  lists:map(fun({{_, Pid}, E}) ->
                         Pid ! {reverse, E, self()},
                         receive
                           Any -> Any
                         end
                       end, ZippedList),
       io:format("*** LOG: Res ~p~n", [lists:reverse(Res)]);
       %{ok, HostName} = inet:gethostname(),
       %io:format("Nodes before: ~p~n", [nodes()]),
       %net_adm:ping(list_to_atom("client@" ++ HostName)),
       %io:format("Nodes after: ~p~n", [nodes()])
    Any -> io:format("*** LOG: ERROR with ~p~n", [Any])
  end,
  master_loop().

create_slaves(X, N) -> create_slaves(X, N, []).
create_slaves(N, N, Acc) -> Acc;
create_slaves(X, N, Acc) ->
  Pid = spawn(fun() -> slave_loop(X) end),
  io:format("*** LOG: Created slave ~p with pid ~p~n", [X, Pid]),
  create_slaves(X + 1, N, [{X, Pid} | Acc]).

slave_loop(X) ->
  receive
    exit_from_master -> exit(exit_from_master);
    {reverse, E, From} -> From ! lists:reverse(E)
  end,
  slave_loop(X).

long_reverse_string(S) -> long_reverse_string(S, 10).
long_reverse_string(S, N) -> master ! {reverse_string, S, N}.

split_string(S, N) -> Len = length(S), Rem = Len rem N, Div = trunc(Len div N), calc_split(S, Rem, Div, []).
calc_split("", 0, _, Acc) -> lists:reverse(Acc);
calc_split(S, 0, Div, Acc) -> calc_split(lists:sublist(S, Div + 1, length(S)), 0, Div, [lists:sublist(S, 1, Div) | Acc]);
calc_split(S, Rem, Div, Acc) -> calc_split(lists:sublist(S, Div + 2, length(S)), Rem - 1, Div, [lists:sublist(S, 1, Div + 1) | Acc]).

