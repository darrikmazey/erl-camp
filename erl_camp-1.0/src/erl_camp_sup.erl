
-module(erl_camp_sup).
-author(darrik@darmasoft.com).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
	CCChild = {campfire_auth_sup, {campfire_auth_sup, start_link, []}, permanent, 2000, supervisor, [campfire_auth]},
	{ok, {{one_for_one, 1, 1}, [CCChild]}}.
