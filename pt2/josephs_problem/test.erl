-module(test).

-export([test/0]).

test() -> 
  joseph:joseph(30, 3),
  joseph:joseph(300, 1001),
  joseph:joseph(3000, 37).

