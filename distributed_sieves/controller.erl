-module(controller).

-export([start/1, rpc_is_prime/1, rpc_close/0]).

start(N) ->
  register(server, self()),
  PrimesList = get_primes(N),
  Pfirst = spawn(fun() -> create_ring(length(PrimesList) - 1, PrimesList) end),
  register(first, Pfirst),
  put(gn, math:pow(lists:nth(length(PrimesList), PrimesList), 2)),
  receive
    ring_created ->
      link(Pfirst),
      server_loop(Pfirst)
  end.

server_loop(Pfirst) ->
  receive
    {new, N} ->
      io:format("You asked for: ~p~n", [N]),
      case N > get(gn) of
        true ->
          rpc:call(amora@federicobruzzone, client, rpc_is_prime, [lists:concat([N, "is uncheckable, too big value"])]),
          server_loop(Pfirst);
        false ->
          Pfirst ! {new, N},
          server_loop(Pfirst)
      end;

    {res, R} ->
      rpc:call(amora@federicobruzzone, client, rpc_is_prime, [R]),
      server_loop(Pfirst);

    close ->
      io:format("I'm closing ..."), unregister(server), unregister(first),
      exit(close)
  end.

rpc_close() -> rpc(close).
rpc_is_prime(N) -> rpc({new, N}).
rpc(M) -> server ! M.

create_ring(0, [H]) ->
  Pnext = whereis(first),
  server ! ring_created,
  sieve:start(H, Pnext, whereis(first));
create_ring(N, PrimesList) ->
  [H | T] = PrimesList,
  Pnext = spawn_link(fun() -> create_ring(N - 1, T) end),
  sieve:start(H, Pnext, whereis(first)).

get_primes(N) -> [X || X <- lists:seq(2, N), is_prime(X)].
is_prime(N) -> is_prime(N, 2).
is_prime(N, N) -> true;
is_prime(N, I) when N rem I =:= 0 -> false;
is_prime(N, I) -> is_prime(N, I + 1).

