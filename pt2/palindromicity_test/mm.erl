-module(mm).

-export([loop/2]).

loop(Id, Server) -> 
  group_leader(whereis(user), self()), link(Server),
  % register(mm, self()),
  io:format("*** LOG: ~p ~p~n", [Id, Server]),
  receive 
    {reverse, S} -> 
      io:format("*** LOG: Receive ~p~n", [S]),
      Server ! {reverse, Id, lists:reverse(S)};
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop(Id, Server).
