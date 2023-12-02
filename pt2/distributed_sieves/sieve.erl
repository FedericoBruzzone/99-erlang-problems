-module(sieve).

-export([loop/3]).

loop(_X, Next, Prime) ->
  receive
    {new, N} -> Next ! {pass, N};
    {res, R} -> send_to_controller(R);
    {pass, N} -> 
      case self() =:= whereis(first) of
        true -> send_to_controller(true);
        false -> handle_prime(N =/= Prime, N rem Prime =:= 0, Next, N)
      end;
    Any -> io:format("*** LOG: Error with ~p~n", [Any])
  end,
  loop(_X, Next, Prime).

handle_prime(true, _, _, _) -> whereis(first) ! {res, true};
handle_prime(false, false, Next, N) -> Next ! {pass, N};
handle_prime(false, true, _, _) -> whereis(first) ! {res, false}.

send_to_controller(Value) -> whereis(controller) ! {res, Value}.
