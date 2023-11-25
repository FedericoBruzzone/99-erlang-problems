-module(hebrew).

-export([loop/2]).

loop(X, Next) ->
  receive
    % ASSUMING THAT Step =/= 0
    {start, Step} -> 
      Next ! {step, Step - 1, Step, self()}; % io:format("*** LOG: loop_node start at ~p with step ~p~n", [X, Step])
    {step, Step, OriginalStep, From} -> 
      handle_step(Step, OriginalStep, From, Next); % io:format("*** LOG: loop_node of ~p step ~p from ~p~n", [X, Step, From])
    {update_next, NewNext} -> 
      handle_newnext(X, NewNext, self()) % io:format("*** LOG: update_next of ~p, old next ~p, new next ~p~n", [X, Next, NewNext])
  end,
  loop(X, Next).

handle_step(1, OriginalStep, From, Next) -> 
  From ! {update_next, Next},
  Next ! {step, OriginalStep, OriginalStep, From}, % io:format("*** LOG: Suicide the next was ~p~n", [Next])
  exit(suicide);
handle_step(Step, OriginalStep, _, Next) ->
  Next ! {step, Step - 1, OriginalStep, self()}.

handle_newnext(X, N, N) -> 
  io:format("Joseph is the Hebrew in position ~p~n", [X]), % io:format("*** LOG: Survive ~p with pid ~p~n", [X, N])
  unregister(handler), exit(survive);
handle_newnext(X, N, _) -> loop(X, N).

