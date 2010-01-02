
-module(erl_camp_sup).
-author(darrik@darmasoft.com).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
	debug:log("erl_camp_sup: starting campfire_auth_sup, campfire_srv_sup"),
	CAChild = {campfire_auth_sup, {campfire_auth_sup, start_link, []}, permanent, 2000, supervisor, [campfire_auth]},
	CSChild = {campfire_srv_sup, {campfire_srv_sup, start_link, []}, permanent, 2000, supervisor, [campfire_srv]},
	{ok, {{one_for_one, 1, 1}, [CAChild, CSChild]}}.
