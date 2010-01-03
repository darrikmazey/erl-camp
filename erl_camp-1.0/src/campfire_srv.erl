
-module(campfire_srv).
-author(darrik@darmasoft.com).

-export([start/0]).
-export([stop/0]).

-export([list_rooms/0]).

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
		#msg_campfire_srv_list_rooms{sender=Sender} ->
			debug:log("campfire_srv: received list_rooms from ~p", [Sender]),
			CA = campfire_auth:find(Sender),
			debug:log("campfire_srv: found ~p", [CA]),
			loop(State);
		M ->
			debug:log("campfire_srv: received unknown message: ~p", [M]),
			loop(State)
	end.

list_rooms() ->
	campfire_srv ! #msg_campfire_srv_list_rooms{sender=self()},
	true.
