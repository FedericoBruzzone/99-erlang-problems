%  12
-module(controller).

-export([start/1]).

start(N) ->
  register(handler, self()),
  Primes = get_primes(N),
  Card = length(Primes),
  First = spawn(fun() -> create_ring(1, Card, Primes) end),
  register(first, First),
  receive
    ring_created -> Controller = spawn(fun() -> link(First), loop(N*N) end),
                    register(controller, Controller),
                    io:format("*** LOG: Controller created at ~p~n", [Controller]),
                    io:format("*** LOG: Ring created~n")
  end.

create_ring(N, N, [H]) ->
  handler ! ring_created,
  io:format("*** LOG: ~p created at ~p (prime ~p) and the next is ~p~n", [N, self(), H, whereis(first)]),
  sieve:loop(N, whereis(first), H);
create_ring(X, N, [H | T]) ->
  Next = spawn_link(fun() -> create_ring(X + 1, N, T) end),
  io:format("*** LOG: ~p created at ~p (prime ~p) and the next is ~p~n", [X, self(), H, Next]),
  sieve:loop(X, Next, H).

loop(Max) ->
  {ok, Hostname} = inet:gethostname(),
  Node = list_to_atom(lists:concat(["amora@", Hostname])),
  io:format("*** LOG: The node is ~p~n", [Node]),
  receive
    {new, N} ->
      io:format("*** LOG: New ~p~n", [N]),
      case N > Max of
        true -> {client, Node} ! {result, "TO BIG"};
        false -> whereis(first) ! {new, N}
      end;
    {res, R} ->
      io:format("*** LOG: Res ~p~n", [R]),
      {client, Node} ! {result, R};
    close -> exit(softly);
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop(Max).

get_primes(N) -> lists:filter(fun(X) -> is_prime(X) end, lists:seq(2, N)).
is_prime(N) -> is_prime(N, 2).
is_prime(N, N) -> true;
is_prime(N, I) when N rem I =:= 0 -> false;
is_prime(N, I) -> is_prime(N, I + 1).
