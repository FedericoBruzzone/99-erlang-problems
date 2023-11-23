-module(tempsys).

-export([startsys/0]).

startsys() ->
  {F, S} = get_lists(),
  PS = lists:map(fun({T, Fn}) -> {T, spawn(fun() -> loop_to_res(T, Fn) end)} end, S),
  PF = lists:map(fun({T, Fn}) -> {T, spawn(fun() -> loop_to_c(T, Fn, PS) end)} end, F),
  lists:foreach(fun({T, Pid}) -> register(T, Pid) end, PF).

get_lists() ->
  F = [{'C', fun(X) -> X end},
       {'K', fun(X) -> X - 273.15 end},
       {'N', fun(X) -> X * 100/33 end}],
  S = [{'C', fun(X) -> X end},
       {'K', fun(X) -> X + 273.15 end},
       {'N', fun(X) -> X * 33/100 end}],
  {F, S}.

loop_to_c(T, Fn, PS) ->
  receive
    {to_c, To, N, Client} ->
      C = Fn(N), Self = self(),
      ToPid = get_toPid(To, PS),
      ToPid ! {to_res, C, Client, Self};

    {res, Res, Client} ->
      io:format("*** LOG: Result ~p~n", [Res]),
      Client ! {res, Res};

    Any -> io:format("*** LOG: Error ~p~n", [Any])
  end,
  loop_to_c(T, Fn, PS).

loop_to_res(T, Fn) ->
  receive
    {to_res, C, Client, Second} ->
      Res = Fn(C),
      Second ! {res, Res, Client};
    Any -> io:format("*** LOG: Error ~p~n", [Any])
  end,
  loop_to_res(T, Fn).

get_toPid(_, []) -> not_ok; % unreachable
get_toPid(X, [{X, ToPid} | _]) -> ToPid;
get_toPid(X, [_ | T] = PS) -> 
  io:format("~p ~p~n", [X, PS]),
  get_toPid(X, T).

