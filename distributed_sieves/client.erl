-module(client).

-export([is_prime/1, close/0, rpc_is_prime/1]).

is_prime(N) ->
  handle_registration(whereis(client)),
  rpc:call(sif@federicobruzzone, controller, rpc_is_prime, [N]),
  receive
    {ToF, N} -> lists:concat(["is ", N, " prime? ", ToF]);
    Any -> Any
  end.

close() ->
  rpc:call(sif@federicobruzzone, controller, rpc_close, []).

handle_registration(undefined) ->
  register(client, self()).
% handle_registration(_) ->
%   ok.

rpc_is_prime(R) -> whereis(client) ! R.


