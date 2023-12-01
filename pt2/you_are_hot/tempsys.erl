-module(tempsys).

-export([startsys/0]).

startsys() -> 
  {Fr_From_c, Sr_From_c} = get_lists(),
  Sr_From_c_PIDS = lists:map(fun({Id, F}) -> 
                                 {Id, spawn(fun() -> loop_sr_from_c(Id, F) end)} 
                             end, Sr_From_c),
  Fr_From_c_PIDS = lists:map(fun({Id, F}) -> 
                                 P = spawn(fun() -> loop_fr_to_c(Id, F, Sr_From_c_PIDS) end),
                                 io:format("~p~n", [P]),
                                 register(Id, P)
                             end, Fr_From_c),
  ok.

loop_fr_to_c(Id, F, Sr_From_c_PIDS) -> 
  receive 
    {to, To, N, Client} -> 
      {_, ToPid} = get_to_pid(Sr_From_c_PIDS, To),
      ToPid ! {to, F(N), Client, self()};
    {res, Client, Res} -> Client ! {res, Res};
    Ok -> io:format("*** LOG: Bad request ~p~n", [Ok]) 
  end,
  loop_fr_to_c(Id, F, Sr_From_c_PIDS).

loop_sr_from_c(Id, F) -> 
  receive 
    {to, N, Client, From} -> From ! {res, Client, F(N)}; 
    Ok -> io:format("*** LOG: Bad request ~p~n", [Ok]) 
  end,
  loop_sr_from_c.

get_to_pid(Sr_From_c_PIDS, To) -> 
  io:format("List: ~p To: ~p~n", [Sr_From_c_PIDS, To]),
  hd(lists:filter(fun({Id, _}) -> Id =:= To end, Sr_From_c_PIDS)).

get_lists() -> 
  Sr_From_c = [{c, fun(X) -> X end}, 
               {f, fun(X) -> X * 9/5 + 32 end}, 
               {k, fun(X) -> X + 273.15 end},
               {n, fun(X) -> X * 33/100 end}],
  Fr_To_c = [{c, fun(X) -> X end},
             {f, fun(X) -> X * 5/9 - 32 end},
             {k, fun(X) -> X - 273.15 end},
             {n, fun(X) -> X * 100/33 end}],
  {Fr_To_c, Sr_From_c}.
