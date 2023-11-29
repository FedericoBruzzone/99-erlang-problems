-module(mm).

-export([start/1,
         is_palindrome/1]).

-define(AT, "@federicobruzzone").
-define(SERVER_MODULE, server).
-define(SERVER_NODE, list_to_atom("server" ++ ?AT)).

start(Pserver) ->
  group_leader(whereis(user), self()),
  io:format("Starting mm~n"),
  Pmm = spawn(fun() -> link(Pserver),
                       loop(0) end),
  register(pmm, Pmm),
  Pmm.

is_palindrome(S) -> rpc({is_palindrome, S}).
rpc(M) -> pmm ! M.

loop(N) ->
  receive
    {is_palindrome, S} ->
      rpc:call(?SERVER_NODE, ?SERVER_MODULE, is_palindrome, [N, S, node()]),
      loop(N + 1);
    Any -> io:format("Received ~p~n", [Any]),
        loop(N)
  end.

