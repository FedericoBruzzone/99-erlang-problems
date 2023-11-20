-module(test).

-export([start/0]).

% Super process dies only if the exit is forced => exit(SuperPid, kill)

start() -> spawn(fun() -> main() end), retstart.
  
main() ->
  process_flag(trap_exit, true), 
  MainPid = self(),
  TrEx_True = spawn(fun() -> loop_true(MainPid) end),
  TrEx_False = spawn(fun() -> loop_false(MainPid) end),
  io:format("Create TrEx_False and TrEx_True from ~p (main)~n", [self()]),
  sleep(10 * 1000),
  receive 
    loop -> exit(TrEx_True, kill), exit(x)
  end.
  % exit(x).
  % exit(kill).

loop_true(Pid) -> 
  process_flag(trap_exit, true), 
  link(Pid), 
  io:format("Loop true with pid ~p from ~p (main)~n", [self(), Pid]),
  wait(loop_true).

loop_false(Pid) -> 
  link(Pid), 
  io:format("Loop false with pid ~p from ~p (main)~n", [self(), Pid]),
  wait(loop_false).

wait(Name) ->
  io:format("Process ~p is in wait~n", [Name]),
  receive
    {'EXIT', Pid, Why} -> io:format("Process ~p (with pid ~p) receive ~p from ~p~n",
                                    [Name, self(), Why, Pid]),
                          status(Name, self()),
                          wait(Name);
    Any -> io:format("We have a problem ~p~n", [Any])
  end.

status(Name, Pid) ->
  case erlang:is_process_alive(Pid) of
    true -> io:format("Process ~p (with pid ~p) is alive~n", [Name, Pid]);
    false -> io:format("Process ~p (with pid ~p) is not alive~n", [Name, Pid])
  end.

sleep(N) -> receive after N -> true end.

