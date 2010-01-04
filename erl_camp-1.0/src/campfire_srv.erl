
-module(campfire_srv).
-author(darrik@darmasoft.com).

-export([start/0]).
-export([stop/0]).

-export([list_rooms/0]).
-export([room_data/1]).
-export([user_data/1]).
-export([me/0]).
-export([is_me/1]).

-export([init/0]).

-include("include/campfire_srv.hrl").
-include("include/campfire_auth.hrl").
-include("include/campfire_data.hrl").

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
		#msg_campfire_srv_req_room{sender=Sender, room_id=RoomId} ->
			debug:log("campfire_srv: received room data request for ~p from ~p", [RoomId, Sender]),
			RoomData = campfire_data:parse_room_data(campfire_request:room_data(Sender, RoomId)),
			Sender ! #msg_campfire_srv_rep_room{sender = self(), room_id=RoomId, data=RoomData},
			loop(State);
		#msg_campfire_srv_req_user{sender=Sender, user_id=UserId} ->
			debug:log("campfire_srv: received user request for ~p from ~p", [UserId, Sender]),
			UserData = campfire_data:parse_user_data(campfire_request:user_data(Sender, UserId)),
			Sender ! #msg_campfire_srv_rep_user{sender = self(), user_id = UserId, data=UserData},
			loop(State);
		#msg_campfire_srv_req_me{sender=Sender} ->
			debug:log("campfire_srv: received me request from ~p", [Sender]),
			UserData = campfire_data:parse_user_data(campfire_request:me_data(Sender)),
			Sender ! #msg_campfire_srv_rep_me{sender = self(), data=UserData},
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

room_data(RoomId) when is_integer(RoomId) ->
	campfire_srv ! #msg_campfire_srv_req_room{sender=self(), room_id=RoomId},
	receive_room_data_reply();
room_data(Room) ->
	case Room of
		#campfire_room{} ->
			campfire_srv ! #msg_campfire_srv_req_room{sender=self(), room_id=Room#campfire_room.id},
			receive_room_data_reply();
			_ -> {err, unknown_room}
	end.

receive_room_data_reply() ->
	receive
		#msg_campfire_srv_rep_room{data=Data} -> Data
	end.

user_data(me) ->
	campfire_srv ! #msg_campfire_srv_req_me{sender=self()},
	receive_me_reply();
user_data(UserId) when is_integer(UserId) ->
	campfire_srv ! #msg_campfire_srv_req_user{sender=self(), user_id=UserId},
	receive_user_data_reply();
user_data(User) ->
	case User of
		#campfire_user{id=UserId} ->
			campfire_srv ! #msg_campfire_srv_req_user{sender=self(), user_id=UserId},
			receive_user_data_reply();
		_ -> {err, unknown_user}
	end.

receive_user_data_reply() ->
	receive
		#msg_campfire_srv_rep_user{data=Data} -> Data
	end.

me() ->
	user_data(me).

receive_me_reply() ->
	receive
		#msg_campfire_srv_rep_me{data=Data} -> Data
	end.

is_me(User) ->
	Me = me(),
	MeId = Me#campfire_user.id,
	UserId = User#campfire_user.id,
	MeId == UserId.
