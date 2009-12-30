
-module(campfire).
-compile(export_all).
%-export([authenticate/3, authenticate/2]).

-include_lib("include/campfire.hrl").

authenticate(Sub, User, Password) -> #campfire_auth{subdomain=Sub, username=User, password=Password}.
authenticate(Sub, User) -> authenticate(Sub, User, "X").

base_uri(#campfire_auth{subdomain=Sub}) -> {campfire_base_uri, Sub ++ ".campfirenow.com"}.

rooms_url({campfire_base_uri, BaseURI}) -> {url, "http://" ++ BaseURI ++ "/rooms.json"};
rooms_url({campfire_auth, Sub, User, Password}) -> rooms_url(base_uri({campfire_auth, Sub, User, Password})).

url_for(CA, rooms) -> rooms_url(CA).
