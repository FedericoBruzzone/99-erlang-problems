-module(client).

-export([is_prime/1, close/0]).

is_prime(N) ->
  {ok, Hostname} = inet:gethostname(),
  Node = list_to_atom(lists:concat(["sif@", Hostname])),
  MaybeClientPid = whereis(client),
  case MaybeClientPid of
    undefined -> register(client, self());
    _ -> ok
  end,
  io:format("*** LOG: The node is ~p~n", [Node]),
  {controller, Node} ! {new, N},
  receive
    {result, R} -> io:format("Is ~p prime? ~p~n", [N, R]);
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end.

close() ->
  {ok, Hostname} = inet:gethostname(),
  Node = list_to_atom(lists:concat(["sif@", Hostname])),
  io:format("*** LOG: The node is ~p~n", [Node]),
  {controller, Node} ! close.
