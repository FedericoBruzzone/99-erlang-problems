-module(p4_ping_pong_server).

-export([start/0, print/1, stop/0]).

start() ->
  % Server = spawn(?MODULE, loop, []),
  Pid = whereis(ping_pong_server),
  case Pid of
     undefined ->
       Server = spawn(fun() -> loop() end),
       register(ping_pong_server, Server);
     _ ->
       io:format("Server already started~n")
  end,
  ok.

print(Term) ->
  ping_pong_server ! {print, Term},
  ok.

stop() ->
  exit(whereis(ping_pong_server), kill), % stop
  unregister(ping_pong_server),
  ok.

loop() ->
  receive
    {print, Term} ->
      io:format("~p~n", [Term]),
      loop();
    stop ->
      io:format("Server stopped~n"),
      erlang:exit(normal);
    Any ->
      io:format("Unknown message: ~p~n", [Any]),
      loop()
  end.
