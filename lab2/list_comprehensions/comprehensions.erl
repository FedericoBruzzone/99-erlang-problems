-module(comprehensions).

-export([start/0]).

squared_int(L) -> [X*X || X <- L, erlang:is_integer(X)].
intersect(L1, L2) -> [X || X <- L1, lists:member(X, L2)].
symmetric_difference(L1, L2) -> [X || X <- L1, not lists:member(X, L2)] ++
                                [X || X <- L2, not lists:member(X, L1)].

start() ->
  io:format("*** (1): squared_int([1, hello, 100, boo, \"boo\", 9]) = ~p~n",
            [squared_int([1, hello, 100, boo, "boo", 9])]),
  io:format("*** (2): intersect([1, 2, 3, 4, 5], [4, 5, 6, 7, 8]) = ~p~n",
            [intersect([1, 2, 3, 4, 5], [4, 5, 6, 7, 8])]),
  io:format("*** (3): symmetric_difference([1, 2, 3, 4, 5], [4, 5, 6, 7, 8]) = ~p~n",
            [symmetric_difference([1, 2, 3, 4, 5], [4, 5, 6, 7, 8])]).
