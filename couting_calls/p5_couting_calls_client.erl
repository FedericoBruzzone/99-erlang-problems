% erl -sname t2
% > c(p5_couting_calls_client).
% > p5_couting_calls_client:d1().
% > p5_couting_calls_client:d2(self()).
% > p5_couting_calls_client:tot().


-module(p5_couting_calls_client).

-export([d1/0,
         d2/1,
         tot/0]).

-define(NODE, 't1@federicobruzzone').
-define(SERVER, p5_couting_calls_server).
-define(D1, d1).
-define(D2, d2).
-define(TOT, tot).
-define(RPC(F, Args), rpc:call(?NODE, ?SERVER, F, Args)).

d1() -> send_via_rpc(?D1, [self()]).
d2(X) -> send_via_rpc(?D2, [self(), X]).
tot() -> send_via_rpc(?TOT, [self()]).

send_via_rpc(F, Args) ->
  ?RPC(F, Args),
  receive M -> io:format("*** Received ~p from ~p~n", [M, ?SERVER]) end.

