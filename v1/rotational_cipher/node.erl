-module(node).

-export([loop/2]).

loop(ROT, Server) -> 
  receive
    {cipher, El, Len} -> Server ! {cipher, El + ROT, Len};
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop(ROT, Server).
