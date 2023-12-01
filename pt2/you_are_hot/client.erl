-module(client).

-export([convert/5]).

convert(from, From, to, To, N) -> 
  whereis(From) ! {to, To, N, self()},
  receive
    {res, Res} -> io:format("Res: ~p~n", [Res])
  end.
