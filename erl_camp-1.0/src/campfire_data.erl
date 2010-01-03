
-module(campfire_data).
-author(darrik@darmasoft.com).

-compile(export_all).

-include("include/campfire_data.hrl").

parse_room_list({struct, [{ <<"rooms">>, Data }]}) ->
	_RoomList = parse_rooms(Data).

parse_rooms([{struct, RoomData}|T]) ->
	RoomName = extract_field(name, RoomData),
	RoomId = extract_field(id, RoomData),
	RoomTopic = extract_field(topic, RoomData),
	RoomMembers = extract_field(membership_limit, RoomData),
	RoomCreated = extract_field(created_at, RoomData),
	RoomUpdated = extract_field(updated_at, RoomData),
	[#campfire_room{name=RoomName, id=RoomId, topic=RoomTopic, membership_limit=RoomMembers, created_at=RoomCreated, updated_at=RoomUpdated}|parse_rooms(T)];
parse_rooms([]) -> [].

extract_field(Field, Data) when is_list(Field) ->
	extract_field(list_to_binary(Field), Data);
extract_field(Field, Data) when is_atom(Field) ->
	extract_field(list_to_binary(atom_to_list(Field)), Data);
extract_field(Field, [ {Field, Value} | _T]) ->
	return_extracted_value(Value);
extract_field(Field, [ {_F, _V} | T]) ->
	extract_field(Field, T);
extract_field(_Field, []) ->
	undefined.

return_extracted_value(Value) when is_binary(Value) ->
	binary_to_list(Value);
return_extracted_value(Value) when is_integer(Value) ->
	Value;
return_extracted_value(null) ->
	undefined.

