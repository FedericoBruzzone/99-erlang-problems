-module(hebrew).

-export([loop/3]).

loop(Id, Next, C) -> 
  receive
    {msg, From, N} -> 
      io:format("*** LOG: C -> ~p N -> ~p~n", [C, N]),
      handle_cn(C =:= N, From, Next, N);
    {update_next, NewNext} -> handle_loop(Id, self(), NewNext, C); 
    Any -> io:format("*** LOG: Bad request ~p~n", [Any])
  end,
  loop(Id, Next, C).

handle_loop(Id, N, N, _) -> io:format("End with ~p~n", [Id]), exit(survive);
handle_loop(Id, _, N, C) -> loop(Id, N, C).

handle_cn(false, From, Next, N) -> 
  % io:format("*** LOG: handle_cn ~p~n", [Next]),
  From ! {update_next, Next}, 
  Next ! {msg, self(), N + 1};
handle_cn(true, _, Next, _) -> 
  % io:format("*** LOG: handle_cn ~p ~p ~p~n", [From, Next, N]),
  Next ! {msg, self(), 1}.
