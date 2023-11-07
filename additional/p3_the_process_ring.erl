-module(p3_the_process_ring).

% -compile(export_all).
-export([start/0]).

start() ->
  N = 1000,
  M = 2,
  Message = "Hello",
  start(M, N, Message, []).

start(M, 0, Message, Pids) ->
  create_ring(Pids, M, Message);
start(M, N, Message, Pids) ->
  % Pid = spawn(fun () -> put(m, M), loop(M, Message) end),
  % Pid = spawn(?MODULE, init, [M]),
  Pid = spawn(fun() -> init(M) end),
  start(M, N - 1, Message, [Pid | Pids]).

create_ring(Pids, M, Message) ->
  Pids2zip = lists:zip(Pids, tl(Pids) ++ [hd(Pids)]),
  lists:foreach(fun({Pid, NextPid}) -> Pid ! {nextPid, NextPid} end, Pids2zip),
  hd(Pids) ! {m_msg, M, Message}.

init(M) ->
  receive
    {nextPid, NextPid} ->
      % io:format("Process ~p received nextPid ~p~n", [self(), NextPid]),
      loop(M, NextPid);
    Any ->
      io:format("ERROR: ~p~n", [Any])
  end.

loop(0, _) ->
  io:format("Done!~n");
loop(M, NextPid) ->
  receive
    {m_msg, 0, Message} ->
      io:format("Process ~p received message ~p~n", [self(), Message]),
      NextPid ! {m_msg, 0, Message},
      loop(0, NextPid);
    {m_msg, _, Message} ->
      io:format("Process ~p received message ~p~n", [self(), Message]),
      NextPid ! {m_msg, M, Message},
      loop(M - 1, NextPid)
  end.
