% erlc *.erl 
% erl -noshell -eval 'test:test()' -s init stop

-module(joseph).

-export([joseph/2]).

joseph(N, Step) -> private_joseph(whereis(handler), N, Step).

private_joseph(undefined, N, Step) ->
  io:format("In a circle of ~p people, killing number ~p~n", [N, Step]),
  register(handler, self()),
  First = spawn(fun() -> create_ring(1, N) end),
  register(first, First),
  receive
    ring_created -> % io:format("*** LOG: Ring created~n"),
      whereis(first) ! {start, Step}
  end;
private_joseph(_, N, Step) ->
  timer:sleep(1000),
  joseph(N, Step).

create_ring(N, N) ->
  whereis(handler) ! ring_created,
  Next = whereis(first),
  hebrew:loop(N, Next);
create_ring(X, N) ->
  Next = spawn(fun() -> create_ring(X + 1, N) end),
  hebrew:loop(X, Next).

