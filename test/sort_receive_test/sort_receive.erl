-module(sort_receive).

-export([test/0]).

test() -> 
  Test = spawn(fun() -> loop(0) end), register(test, Test).

loop(N) -> 
  receive
    {n, N} -> io:format("*** LOG: The ~p is ~p~n", [n, N])
  end,
  loop(N + 1).
