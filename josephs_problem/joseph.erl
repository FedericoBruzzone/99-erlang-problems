-module(joseph).

-export([joseph/2]).

joseph(N, Step) -> 
  Handler = spawn(fun() -> create_ring(N) end),
  register(handler, Handler).

create_ring(0) -> 


