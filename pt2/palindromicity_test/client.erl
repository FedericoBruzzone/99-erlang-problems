-module(client).

-export([
  start/0,
  close/0,
  do_reverse/1
]).

start() ->
  {ok, Hostname} = inet:gethostname(),
  ServerNode = list_to_atom("server@" ++ Hostname),
  MM1Node = list_to_atom("mm1@" ++ Hostname),
  MM2Node = list_to_atom("mm2@" ++ Hostname),
  Server = spawn(ServerNode, server, loop, []),
  MM1 = spawn(MM1Node, mm, loop, [1, Server]),
  MM2 = spawn(MM2Node, mm, loop, [2, Server]),
  Client = spawn(fun() -> loop(MM1, MM2) end),
  register(client, Client).

loop(MM1, MM2) ->
  group_leader(whereis(user), self()), link(MM1), link(MM2),
  io:format("*** LOG: ~p ~p~n", [MM1, MM2]),
  %{mm, MM1Node} ! hello,
  %{mm, MM2Node} ! hello,
  receive
    {reverse, S} ->
      io:format("*** LOG: Receive ~p~n", [S]),
      {Left, Right} = split_string(S),
      io:format("*** LOG: Left ~p, Right ~p~n", [Left, Right]),
      MM1 ! {reverse, Left},
      MM2 ! {reverse, Right};
    close -> exit(close);
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop(MM1, MM2).

do_reverse(S) -> whereis(client) ! {reverse, S}.
close() -> whereis(client) ! close.

split_string(S) -> split_string_helper(length(S) rem 2, S).
split_string_helper(0, S) -> {lists:sublist(S, 1, length(S) div 2),
                              lists:sublist(S, length(S) div 2 + 1, length(S))};
split_string_helper(_, S) -> {lists:sublist(S, 1, trunc(length(S) div 2)),
                              lists:sublist(S, length(S) div 2 + 1, length(S))}.
