
-module(campfire_data).
-author(darrik@darmasoft.com).

-compile(export_all).

-include("include/campfire_data.hrl").

parse_room_list({<<"rooms">>, Data}) ->
	#campfire_rooms{rooms=parse_rooms(Data)};
parse_room_list([{<<"rooms">>, Data}]) ->
	#campfire_rooms{rooms=parse_rooms(Data)}.

parse_rooms([H|T]) ->
	debug:log("parse_rooms: H = ~p", H),
	[parse_room_data(H)|parse_rooms(T)];
parse_rooms([]) -> [].

parse_room_data([{<<"room">>, {struct, PropList}}]) ->
	parse_room_data(PropList);
parse_room_data({<<"room">>, {struct, PropList}}) ->
	parse_room_data(PropList);
parse_room_data({struct, PropList}) ->
	parse_room_data(PropList);
parse_room_data(PropList) when is_list(PropList) ->
	debug:log("parse_room_data: PropList = ~p", [PropList]),
	RoomName = extract_field(name, PropList),
	RoomId = extract_field(id, PropList),
	RoomTopic = extract_field(topic, PropList),
	RoomOpen = extract_field(open_to_guests, PropList),
	RoomMember = extract_field(membership_limit, PropList),
	RoomCreated = extract_field(created_at, PropList),
	RoomUpdated = extract_field(updated_at, PropList),
	RoomUsers = #campfire_users{users=parse_users(extract_raw_field(users, PropList))},
	RoomFull = extract_field(full, PropList),
	#campfire_room{name=RoomName, id=RoomId, topic=RoomTopic, open_to_guests=RoomOpen, membership_limit=RoomMember, created_at=RoomCreated, updated_at=RoomUpdated, full=RoomFull, users=RoomUsers}.

parse_user_list({<<"users">>, Data}) ->
	#campfire_users{users=parse_users(Data)}.

parse_users([H|T]) ->
	[parse_user_data(H)|parse_users(T)];
parse_users(undefined) -> [];
parse_users([]) -> [].
	
parse_user_data([{<<"user">>, {struct, PropList}}]) ->
	parse_user_data(PropList);
parse_user_data({<<"user">>, {struct, PropList}}) ->
	parse_user_data(PropList);
parse_user_data({struct, PropList}) ->
	parse_user_data(PropList);
parse_user_data(PropList) when is_list(PropList) ->
	UserId = extract_field(id, PropList),
	UserType = extract_field(type, PropList),
	UserCreated = extract_field(created_at, PropList),
	UserAdmin = extract_field(admin, PropList),
	UserEmail = extract_field(email_address, PropList),
	UserName = extract_field(name, PropList),
	#campfire_user{id=UserId, type=UserType, created_at=UserCreated, admin=UserAdmin, email_address=UserEmail, name=UserName}.

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

extract_raw_field(Field, Data) when is_list(Field) ->
	extract_raw_field(list_to_binary(Field), Data);
extract_raw_field(Field, Data) when is_atom(Field) ->
	extract_raw_field(list_to_binary(atom_to_list(Field)), Data);
extract_raw_field(Field, [ {Field, Value} | _T]) ->
	Value;
extract_raw_field(Field, [{_F, _V} | T]) ->
	extract_raw_field(Field, T);
extract_raw_field(_Field, []) ->
	undefined.
return_extracted_value(Value) when is_binary(Value) ->
	binary_to_list(Value);
return_extracted_value(Value) when is_integer(Value) ->
	Value;
return_extracted_value(Value) when is_atom(Value) ->
	Value;
return_extracted_value(null) ->
	undefined.

