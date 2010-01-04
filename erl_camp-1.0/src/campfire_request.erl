
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
			{ok, {{_Version, 200, _ReasonPhrase}, _Headers, Body}} = http:request(Url),
			{struct, Data} = mochijson2:decode(Body),
			Data
	end.

room_list_url(Sub, User, Pass) ->
	lists:flatten(["http://", User, ":", Pass, "@", Sub, ".campfirenow.com/rooms.json"]).
