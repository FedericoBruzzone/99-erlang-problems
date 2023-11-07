% c(p4_ping_pong_server).
% c(p4_ping_pong_client).
% p4_ping_pong_server:start().
% p4_ping_pong_client:start().
% - Check if the two Pids are in erlang:processes() using lists:member(E, L)
% p4_ping_pong_server:stop().
% - Check if the two Pids are still in erlang:processes() using lists:member(E, L)

-module(p4_ping_pong_client).

-export([start/0]).

start() ->
  link(whereis(ping_pong_server)),
  io:format("The process ~p know ~p~n", [self(), whereis(ping_pong_server)])
  self().
