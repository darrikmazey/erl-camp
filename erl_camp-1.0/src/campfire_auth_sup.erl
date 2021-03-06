
-module(campfire_auth_sup).
-author(darrik@darmasoft.com).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
	debug:log("campfire_auth_sup: starting campfire_auth"),
	Child = {campfire_auth, {campfire_auth, start, []}, permanent, 2000, worker, [campfire_auth]},
	{ok, {{one_for_one, 1, 1}, [Child]}}.
