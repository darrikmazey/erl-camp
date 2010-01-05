
-module(campfire_request).
-author(darrik@darmasoft.com).

-export([room_list/1]).

-compile(export_all).

-include("include/campfire_auth.hrl").

room_list(Sender) ->
	CA = campfire_auth:find(Sender),
	case CA of
		{ok, notfound} -> [];
		#campfire_auth{subdomain=Sub, username=User, password=Pass} ->
			Url = room_list_url(Sub, User, Pass),
			Data = fetch_json_url(Url),
			Data
	end.

room_data(Sender, Id) ->
	CA = campfire_auth:find(Sender),
	case CA of
		{ok, notfound} -> [];
		#campfire_auth{subdomain=Sub, username=User, password=Pass} ->
			Url = room_url(Sub, User, Pass, Id),
			Data = fetch_json_url(Url),
			Data
	end.

user_data(Sender, Id) ->
	CA = campfire_auth:find(Sender),
	case CA of
		{ok, notfound} -> [];
		#campfire_auth{subdomain=Sub, username=User, password=Pass} ->
			Url = user_url(Sub, User, Pass, Id),
			Data = fetch_json_url(Url),
			Data
	end.

me_data(Sender) ->
	CA = campfire_auth:find(Sender),
	case CA of
		{ok, notfound} -> [];
		#campfire_auth{subdomain=Sub, username=User, password=Pass} ->
			Url = me_url(Sub, User, Pass),
			Data = fetch_json_url(Url),
			Data
	end.

transcript(Sender, Id) ->
	CA = campfire_auth:find(Sender),
	case CA of
		{ok, notfound} -> [];
		#campfire_auth{subdomain=Sub, username=User, password=Pass} ->
			Url = transcript_url(Sub, User, Pass, Id),
			Data = fetch_json_url(Url),
			Data
	end.

room_list_url(Sub, User, Pass) ->
	lists:flatten(["http://", User, ":", Pass, "@", Sub, ".campfirenow.com/rooms.json"]).

room_url(Sub, User, Pass, Id) ->
	lists:flatten(["http://", User, ":", Pass, "@", Sub, ".campfirenow.com/room/", integer_to_list(Id), ".json"]).

user_url(Sub, User, Pass, Id) ->
	lists:flatten(["http://", User, ":", Pass, "@", Sub, ".campfirenow.com/users/", integer_to_list(Id), ".json"]).

me_url(Sub, User, Pass) ->
	lists:flatten(["http://", User, ":", Pass, "@", Sub, ".campfirenow.com/users/me.json"]).

transcript_url(Sub, User, Pass, Id) ->
	lists:flatten(["http://", User, ":", Pass, "@", Sub, ".campfirenow.com/room/", integer_to_list(Id), "/transcript.json"]).

fetch_json_url(Url) ->
	debug:log("campfire_request: requesting url:~n~p", [Url]),
	FullResponse = http:request(Url),
	Rep = case FullResponse of
		{ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} ->
			{struct, Data} = mochijson2:decode(Body),
			debug:log("url data: ~p", Data),
			Data
		end,
	Rep.

