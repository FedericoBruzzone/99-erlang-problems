-module(joseph).

-export([joseph/2]).

joseph(N, Step) -> 
  register(handler, self()),
  First = spawn(fun() -> create_ring(1, N) end),
  register(first, First),
  receive
    ring_created -> 
      io:format("*** LOG: Ring created~n"),
      whereis(first) ! {start, Step}
  end.

create_ring(N, N) -> 
  whereis(handler) ! ring_created,
  Next = whereis(first),
  loop_node(N, Next);
create_ring(X, N) -> 
  Next = spawn(fun() -> create_ring(X + 1, N) end),
  io:format("*** LOG: Create node with pid ~p~n", [Next]),
  loop_node(X, Next).

loop_node(X, Next) -> 
  receive
    {start, Step} -> % assuming that Step =/= 0
      io:format("*** LOG: loop_node start at ~p with step ~p~n", [X, Step]),
      Next ! {step, Step - 1, Step, self()};

    {step, Step, OriginalStep, From} ->
      io:format("*** LOG: loop_node of ~p step ~p from ~p~n", 
                [X, Step, From]),
      handle_step(Step, OriginalStep, From, Next);

    {update_next, NewNext} -> 
      io:format("*** LOG: update_next of ~p, old next ~p, new next ~p~n",
                [X, Next, NewNext]),
      handle_newnext(X, NewNext, self())
  end,
  loop_node(X, Next).

handle_step(1, OriginalStep, From, Next) ->
  From ! {update_next, Next},
  Next ! {step, OriginalStep, OriginalStep, From},
  io:format("*** LOG: Suicide the next was ~p~n", [Next]),
  timer:sleep(1000),
  exit(suicide);
handle_step(Step, OriginalStep, _, Next) ->
  Next ! {step, Step - 1, OriginalStep, self()}.

handle_newnext(X, N, N) -> io:format("*** LOG: Rurvive ~p with pid ~p~n", 
                                     [X, N]);
handle_newnext(X, N, _) -> loop_node(X, N).
