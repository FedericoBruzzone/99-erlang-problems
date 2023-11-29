-module(client).

-export([
          start/0,
          close/0,
          is_palindrome/1
        ]).

% -define(CLIENT_MODULE, client).
-define(MM_MODULE, mm).
-define(SERVER_MODULE, server).

-define(AT, "@federicobruzzone").
% -define(CLIENT_NODE, list_to_atom("client" ++ ?AT)).
-define(MM1_NODE,    list_to_atom("mm1" ++ ?AT)).
-define(MM2_NODE,    list_to_atom("mm2" ++ ?AT)).
-define(SERVER_NODE, list_to_atom("server" ++ ?AT)).

start() -> Pclient = spawn(fun() -> create_net() end),
           register(client, Pclient).

create_net() ->
  Pserver = rpc:call(?SERVER_NODE, ?SERVER_MODULE, start, []),
  Pmm1 = rpc:call(?MM1_NODE, ?MM_MODULE, start, [Pserver]),
  Pmm2 = rpc:call(?MM2_NODE, ?MM_MODULE, start, [Pserver]),
  io:format("Pmm1: ~p Pmm2: ~p Pserver: ~p~n", [Pmm1, Pmm2, Pserver]),
  link(Pmm1), link(Pmm2),
  loop().

loop() ->
  receive
    {is_palindrome, S} ->
      io:format("Checking ~p~n", [S]),
      N = split_string(S),
      {Left, Right} = N,
      rpc:call(?MM1_NODE, ?MM_MODULE, is_palindrome, [Left]),
      rpc:call(?MM2_NODE, ?MM_MODULE, is_palindrome, [lists:reverse(Right)]),
      loop();
    stop -> exit(stop)
  end.

close() -> rpc(stop).
is_palindrome(S) -> rpc({is_palindrome, S}).
rpc(M) -> client ! M.

split_string(S) ->
  case length(S) rem 2 =:= 0 of
    true -> {lists:sublist(S, 1, length(S) div 2),
             lists:sublist(S, (length(S) div 2) + 1, length(S))};
    false -> {lists:sublist(S, 1, (length(S) div 2) + 1),
             lists:sublist(S, (length(S) div 2) + 1, length(S))}
  end.


