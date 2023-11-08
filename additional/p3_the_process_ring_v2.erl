-module(p3_the_process_ring_v2).

-export([start/0, start/3, create/3, loop/2]).

start() ->
  start(2, 5, "Hello").

start(M, N, Msg) ->
  PidHandler = whereis(first_node),
  case PidHandler of
    undefined ->
      % register(first_node, spawn(fun() -> create(N, 1, self()) end)), % DOES NOT WORK, maybe beacause of the self() is internal to the lambda
      register(first_node, spawn(?MODULE, create, [N, 1, self()])),
      io:format("___START: Handler start at ~p~n", [self()]);
    _ ->
      io:format("___START: Handler already started at ~p~n", [PidHandler])
  end,
  receive
    ring_created  ->
      io:format("___START: The ring is created~n"),
      ok;
    Any ->
      io:format("___START: Unexpected message ~p~n", [Any]),
      exit(unexpected_message)
  after 10000 ->
    unregister(first_node), % DOES NOT WORK
    exit(ring_not_created)
  end.
  % Handle next steps

create(1, S, Handler) ->
  io:format("___CREATE: Node ~p (id: ~p) point to ~p (id: ~p)~n", [self(), S, whereis(first_node), 1]),
  Handler ! ring_created;
create(N, S, Handler) ->
  % Next = spawn(fun() -> create(N - 1, S + 1, Handler) end), % DOES NOT WORK
  Next = spawn(?MODULE, create, [N - 1, S + 1, Handler]),
  io:format("___CREATE: Node ~p (id: ~p) point to ~p (id: ~p)~n", [self(), S, Next, S + 1]),
  loop(Next, N).

loop(Next, N) ->
  ok.
