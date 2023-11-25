% ring:start(7, [fun(X) -> X*N end || N <- lists:seq(1, 7)]).
% ring:send_message(1).
% ring:send_message(1, 10).

-module(ring).

-export([
          start/2,
          send_message/1,
          send_message/2,
          stop/0
        ]).

start(N, L) -> 
  Handler = spawn(fun() -> loop_handler(N) end),
  First = spawn(fun() -> create_ring(1, N, L) end),
  register(first, First),
  register(handler, Handler).

loop_handler(N) ->
  receive
    ring_created -> io:format("*** LOG: Ring created ~n");
    {sm1, X} -> whereis(first) ! {sm1, X, N};
    {sm2, X, M} -> whereis(first) ! {sm1, X, N*M};
    stop -> whereis(first) ! stop
  end,
  loop_handler(N).

create_ring(N, N, [H]) -> 
  whereis(handler) ! ring_created, io:format("*** LOG: ~p (~p) --> ~p (~p) ~n", [N, self(), N - N + 1, whereis(first)]),
  loop_node(whereis(first), H);
create_ring(X, N, [H | T]) ->
  Next = spawn_link(fun() -> create_ring(X + 1, N, T) end), io:format("*** LOG: ~p (~p) --> ~p (~p) ~n", [X, self(), X + 1, Next]),
  loop_node(Next, H).

loop_node(Next, F) -> 
  receive
    {sm1, X, N} -> node_helper(Next, F, X, N);
    {sm2, X, M} -> node_helper(Next, F, X, M);
    stop -> exit(softly)
  end,
  loop_node(Next, F).

node_helper(_, F, X, 0) -> io:format("~p~n", [F(X)]);
node_helper(Next, F, X, N) -> Next ! {sm1, F(X), N - 1}.

send_message(X) -> whereis(handler) ! {sm1, X}.
send_message(X, N) -> whereis(handler) ! {sm2, X, N}.
stop() -> whereis(handler) ! stop.

