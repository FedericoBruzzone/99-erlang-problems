-module(client).

-export([start/0, cipher/2, close/0]).

start() -> 
  {ok, HN} = inet:gethostname(),
  SERVER_NODE = list_to_atom(lists:concat(["server@" ++ HN])),
  Server = spawn(SERVER_NODE, server, loop, []),
  Client = spawn(fun() -> loop(Server) end),
  register(client, Client).

loop(Server) ->
  receive
    {cipher, L, ROT} -> 
      Len = length(L),
      Nodes = create_net(1, Len + 1, ROT, Server, []),
      put(nodes, Nodes),
      io:format("*** LOG: ~p =:= ~p~n", [Len, length(Nodes)]),
      Zipped = lists:zip(Nodes, L),
      lists:foreach(fun({Pid, El}) -> 
                      Pid ! {cipher, El, Len}
                    end, Zipped);
    {cipher_done, Res} -> 
      Nodes = get(nodes),
      lists:foreach(fun(X) -> unregister(X) end, Nodes),
      io:format("*** LOG: Res ~p~n", [Res]);
    close -> exit(close);
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop(Server).

create_net(Len, Len, ROT, Server, Acc) -> Acc; 
create_net(N, Len, ROT, Server, Acc) ->
  New = spawn_link(fun() -> node:loop(ROT, Server) end),
  create_net(N + 1, Len, ROT, Server, [New | Acc]).

cipher(L, ROT) -> send_msg({cipher, L, ROT}).
close() -> send_msg(close).

send_msg(M) -> whereis(client) ! M.
