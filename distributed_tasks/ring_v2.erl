-module(ring_v2).

-export([
          start/2,
          send_message/1,
          send_message/2,
          stop/0
        ]).

start(N, L) ->
  First = spawn(fun() -> create_ring(1, N, L) end),
  register(first, First),
  put(n, N), ring_created.

create_ring(N, N, [H]) -> io:format("*** LOG: ~p (~p) --> ~p (~p) ~n", [N, self(), N - N + 1, whereis(first)]),
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
node_helper(Next, F, X, N) ->
  Next ! {sm1, F(X), N - 1}.

send_message(X) -> whereis(first) ! {sm1, X, get(n)}.
send_message(X, M) -> whereis(first) ! {sm2, X, get(n)*M}.
stop() -> whereis(first) ! stop.

% ring_v2:start(7, [fun(X) -> X*N end || N <- lists:seq(1, 7)]).
% ring_v2:send_message(1).
% ring:send_message(1, 10).

