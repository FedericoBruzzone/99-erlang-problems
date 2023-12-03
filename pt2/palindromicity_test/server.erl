-module(server).

-export([loop/0]).

loop() -> 
  group_leader(whereis(user), self()),
  io:format("*** LOG: Server~n"),
  loop(1, []).

loop(N, Acc) -> 
  receive
    {reverse, N, S} -> 
      io:format("*** LOG: Receive ~p from ~p~n", [S, N]),
      update_loop(N, S, Acc);
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end.

update_loop(1, S, _) -> loop(2, S);
update_loop(2, S, Acc) -> 
  io:format("*** LOG: RES -> ~p~n", [S ++ Acc]),
  loop(1, []).
  
  
