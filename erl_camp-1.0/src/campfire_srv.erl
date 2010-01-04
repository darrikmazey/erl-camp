
-module(campfire_srv).
-author(darrik@darmasoft.com).

-export([start/0]).
-export([stop/0]).

-export([list_rooms/0]).

-export([init/0]).

-include("include/campfire_srv.hrl").
-include("include/campfire_auth.hrl").

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
		#msg_campfire_srv_req_rooms{sender=Sender} ->
			debug:log("campfire_srv: received list_rooms from ~p", [Sender]),
			RoomList = campfire_data:parse_room_list(campfire_request:room_list(Sender)),
			Sender ! #msg_campfire_srv_rep_rooms{sender = self(), data=RoomList},
			loop(State);
		M ->
			debug:log("campfire_srv: received unknown message: ~p", [M]),
			loop(State)
	end.

list_rooms() ->
	campfire_srv ! #msg_campfire_srv_req_rooms{sender=self()},
	receive
		#msg_campfire_srv_rep_rooms{data=Data} -> Data
	end.
