-module(server).

-export([loop/0]).

loop() ->
  group_leader(whereis(user), self()),
  process_flag(trap_exit, true),
  io:format("*** LOG: Start server~n"),
  receive
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop().
