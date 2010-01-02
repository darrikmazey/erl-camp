
-module(erl_camp).
-author(darrik@darmasoft.com).

-behaviour(application).

-export([start/2, stop/1]).


start(_Type, _StartArgs) ->
	erl_camp_sup:start_link().

stop(_State) ->
	ok.
