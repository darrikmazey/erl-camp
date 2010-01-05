
%% campfire auth die request
-record(msg_campfire_srv_die, { sender, why }).

%% campfire room list request
-record(msg_campfire_srv_req_rooms, { sender }).
%% campfire room list reply
-record(msg_campfire_srv_rep_rooms, { sender, data }).

%% campfire room data request
-record(msg_campfire_srv_req_room, { sender, room_id }).
%% campfire room data reply
-record(msg_campfire_srv_rep_room, { sender, room_id, data }).

%% campfire user data request
-record(msg_campfire_srv_req_user, { sender, user_id }).
%% campfire user data reply
-record(msg_campfire_srv_rep_user, { sender, user_id, data} ).

%% campfire me data request
-record(msg_campfire_srv_req_me, { sender }).
%% campfire me data reply
-record(msg_campfire_srv_rep_me, { sender, data }).

%% campfire transcript request
-record(msg_campfire_srv_req_transcript, { sender, room_id, date=today }).
%% campfire transcript reply
-record(msg_campfire_srv_rep_transcript, { sender, room_id, date, data }).
