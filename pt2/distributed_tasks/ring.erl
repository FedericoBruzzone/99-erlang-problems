% erlc *erl; cat input.txt | erl

-module(ring).

-export([
        start/2,
        send_message/1,
        send_message/2,
        stop/0
        ]).

start(N, L) ->
  First = spawn(fun() -> create_ring(1, N, L) end),
  register(first, First).

create_ring(N, N, [H]) ->
  io:format("*** LOG: ~p start at ~p and the next is ~p~n", [N, self(), whereis(first)]),
  node_loop(N, H, whereis(first));
create_ring(X, N, [H | T]) ->
  Next = spawn_link(fun() -> create_ring(X + 1, N, T) end),
  io:format("*** LOG: ~p start at ~p and the next is ~p~n", [X, self(), Next]),
  node_loop(X, H, Next).

node_loop(X, F, Next) ->
  receive
    {compute, V, 0} -> io:format("*** LOG: Result ~p~n", [V]);
    {compute, V, N} ->
    io:format("*** LOG: ~p ~p ~p ~p~n", [V, N, Next, whereis(first)]),
      case Next =:= whereis(first) of
        true -> Next ! {compute, F(V), N - 1};
        false -> Next ! {compute, F(V), N}
      end;
    {stop, Why} -> exit(Why);
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  node_loop(X, F, Next).

send_message(X) -> send_message(X, 1).
send_message(V, N) -> whereis(first) ! {compute, V, N}.
stop() -> whereis(first) ! {stop, softly}.
