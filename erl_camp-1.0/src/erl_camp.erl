
-module(erl_camp).
-author(darrik@darmasoft.com).

-behaviour(application).

-export([start/0, start/2, stop/1]).

start() ->
	application:start(erl_camp).

start(_Type, _StartArgs) ->
	%debug:log_to(console, {}),
	debug:log_to(file, {filename, "erl_camp.log"}),
	debug:log("erl_camp: initializing"),
	erl_camp_sup:start_link().

stop(_State) ->
	debug:log("erl_camp: stopping"),
	ok.
