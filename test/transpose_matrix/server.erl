-module(server).

-export([start/0]).

start() -> 
  Server = spawn(fun() -> loop() end),
  register(server, Server).

loop() ->
  receive
    {start, Max_I, Max_J} -> loop(1, Max_I, 1, Max_J)
  end.

loop(_, _, Max_J, Max_J) -> end_loop;
loop(Max_I, Max_I, J, Max_J) -> io:format("~n"), loop(1, Max_I, J + 1, Max_J);
loop(I, Max_I, J, Max_J) -> 
  receive
    {res, H, I, J} -> io:format("~p ", [H])
  end,
  loop(I + 1, Max_I, J, Max_J).
  

