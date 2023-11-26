-module(atm).

-export([
         start/1,
         deposit/3,
         withdraw/3,
         balance/2
        ]).

start(Id) -> 
  Aid = id_to_atom(Id),
  Pid = spawn(fun() -> loop_atm(Aid, 5000) end),
  register(Aid, Pid).

loop_atm(Aid, Amount) -> ok.
  
deposit(DNode, Id, Amout) -> 
  Aid = id_to_atom(Id),
  {dispatcher, DNode} ! {deposit, Amount, Aid, 
  .
withdraw(DNode, Id, Amount) ->
  Aid = id_to_atom(Id).
balance(DNode, Id)
  Aid = id_to_atom(Id).

id_to_atom(Id) -> list_to_atom(lists:concat(["mm", Id])).
