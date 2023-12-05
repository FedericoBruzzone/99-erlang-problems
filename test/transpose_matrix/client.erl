-module(client).

-export([start/0]).

start() ->
  A = [[1,2,3], [4,5,6], [7,8,9]],
  Client = spawn(fun() -> client_loop(A) end).

client_loop(A) ->
  Max_I = length(A),
  Max_J = length(hd(A)),
  L = create_nodes(A, 1, Max_I + 1, []),
  ServerNode = list_to_atom(lists:concat(["server", "@MacBook-Pro-di-Federico"])),
  {server, ServerNode} ! {start, Max_I + 1, Max_J + 1},
  lists:foreach(fun(X) -> X ! {calc, ServerNode} end, L).

create_nodes([], I, I, Acc) -> Acc;
create_nodes([H | T], I, N_Rows, Acc) ->
  create_nodes(T, I + 1, N_Rows, [spawn_link(fun() -> node_loop(H, I) end) | Acc]).

node_loop(L, I) ->
  io:format("*** LOG: Start node ~p at ~p with i ~p~n", [self(), L, I]),
  receive
    {calc, ServerNode} -> lists:foreach(fun({J, H}) ->
                            {server, ServerNode} ! {res, H, I, J}
                          end, lists:enumerate(L))
  end.

