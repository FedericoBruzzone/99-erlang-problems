-module(p3_the_process_ring_v2).

-export([start/0, stop/0]).

start() ->
  start(2, 5, "Hello").

start(M, N, Msg) ->
  register(handler, self()),
  MaybeFirstNode = whereis(first_node),
  case MaybeFirstNode of
    undefined ->
      FirstNode = spawn(fun() -> create(M - 1, N - 1) end),
      register(first_node, FirstNode),
      io:format("___START: First node started at ~p~n", [FirstNode]);
    _ ->
      stop(), start(M, N, Msg)
  end,
  io:format("___START: Waiting for ring creation~n"),
  receive
    ring_created -> ok;
    _ -> io:format("___START: Unexpected message~n")
    after 5000 -> exit(after1000)
  end,
  io:format("___START: Ring created~n"),
  first_node ! {M, Msg}.

stop() ->
  io:format("___STOP: Stopping ring~n"),
  exit(whereis(first_node), kill),
  unregister(first_node).

create(M, 0) ->
  % first_node ! ring_created,
  handler ! ring_created,
  io:format("_______CREATE: Ring created~n"),
  loop(first_node, M);
create(M, N) ->
  Pid = spawn(fun() -> create(M, N - 1) end),
  io:format("_______CREATE: Node ~p created at ~p~n", [N, Pid]),
  loop(Pid,  M).

loop(Next, M) ->
  receive
    {0, Msg} ->
      io:format("______LOOP: Node ~p is sending ~p to ~p -- Last message~n", [self(), Msg, Next]),
      Next ! {0, Msg};
    {_, Msg} ->
      io:format("______LOOP: Node ~p is sending ~p to ~p~n", [self(), Msg, Next]),
      Next ! {M, Msg},
      loop(Next, M - 1)
  end.

