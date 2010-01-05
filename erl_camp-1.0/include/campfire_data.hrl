
%% rooms
-record(campfire_rooms, {rooms=[]}).

%% room
-record(campfire_room, { id, name, topic, membership_limit, created_at, updated_at, full, open_to_guests, users=[] }).

%% users
-record(campfire_users, {users=[]}).

%% user
-record(campfire_user, { id, type, created_at, admin, email_address, name }).

%% transcript
-record(campfire_transcript, { room_id, date, data }).

%% message
-record(campfire_message, { type, room_id, created_at, body, id, user_id }).
