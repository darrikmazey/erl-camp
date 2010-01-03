
%% roomlist
-record(campfire_rooms, {rooms=[]}).

%% room
-record(campfire_room, { id, name, topic, membership_limit, created_at, updated_at }).
