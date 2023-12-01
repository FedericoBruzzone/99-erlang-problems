-module(client).

-export([long_reverse_string/0]).

long_reverse_string() ->
  {ok, HostName} = inet:gethostname(),
  net_adm:ping(list_to_atom("master@" ++ HostName)),

  % 1. {master, list_to_atom("master@" ++ HostName)} ! {reverse_string, "ciaocomestai?", 10}.
  % 2. rpc:call(list_to_atom("master@" ++ HostName), master, long_reverse_string, ["ciaocomestai?"]).
  global:send(whereis(master), {reverse_string, "ciaocomestai?", 10}).


