-module(sieve).

-export([start/3]).

start(Prime, Pnext, Pfirst) ->
  receive
    {new, N}  -> handle_rem_4(Prime, N, Pnext, Pfirst), start(Prime, Pnext, Pfirst);
    {pass, N} -> handle_rem_5(self() =:= Pfirst, Prime, N, Pnext, Pfirst), start(Prime, Pnext, Pfirst);
    {res, R}  -> whereis(server) ! {res, R}, start(Prime, Pnext, Pfirst)
  end.

handle_rem_5(true, _, N, _, _)                            -> whereis(server) ! {res, {true, N}};
handle_rem_5(false, Prime, N, Pnext, Pfirst)              -> handle_rem_4(Prime, N, Pnext, Pfirst).
handle_rem_4(N, N, _, Pfirst)                             -> Pfirst ! {res, {true, N}};
handle_rem_4(Prime, N, Pnext, _)  when N rem Prime =/= 0  -> Pnext ! {pass, N};
handle_rem_4(Prime, N, _, Pfirst) when N rem Prime =:= 0  -> Pfirst ! {res, {false, N}}.

