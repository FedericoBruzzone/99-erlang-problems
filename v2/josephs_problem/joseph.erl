-module(joseph).

-export([joseph/2]).

joseph(N, C) ->
  register(master, self()),
  First = spawn(fun() -> create_ring(1, N - 1, C) end),
  register(first, First),
  receive
    ring_created -> first ! {msg, self(), 1}
  end.

create_ring(N, N, C) ->
  io:format("~p ~p~n", [N, N]),
  whereis(master) ! ring_created,
  io:format("The next of ~p (~p) is ~p (~p)~n", [self(), N, whereis(master), 1]),
  hebrew:loop(N, whereis(first), C);
create_ring(X, N, C) ->
  Next = spawn_link(fun() -> create_ring(X + 1, N, C) end),
  io:format("The next of ~p (~p) is ~p (~p)~n", [self(), X, Next, X + 1]),
  hebrew:loop(X, Next, C).

