
%% campfire auth die request
-record(msg_campfire_srv_die, { sender, why }).

%% campfire room list request
-record(msg_campfire_srv_req_rooms, { sender }).
%% campfire room list request reply
-record(msg_campfire_srv_rep_rooms, { sender, data }).
