
-module(campfire_srv).
-author(darrik@darmasoft.com).

-export([start/0]).
-export([stop/0]).

-export([init/0]).

-include("include/campfire_srv.hrl").

start() ->
	case whereis(campfire_srv) of
		undefined ->
			register(campfire_srv, Pid = spawn_link(campfire_srv, init, []));
		Pid ->
			false
	end,
	{ok, Pid}.

stop() ->
	campfire_srv ! #msg_campfire_srv_die{},
	true.

init() ->
	debug:log("campfire_srv: initializing"),
	loop([]).

loop(State) ->
	receive
		#msg_campfire_srv_die{} ->
			debug:log("campfire_srv: shutting down"),
			true;
		M ->
			debug:log("campfire_srv: received unknown message: ~p", [M]),
			loop(State)
	end.

