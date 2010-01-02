
-module(campfire_srv_sup).
-author(darrik@darmasoft.com).

-behaviour(supervisor).

-export([start_link/0]).
-export([init/1]).

start_link() ->
	supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init(_) ->
	debug:log("campfire_srv_sup: starting campfire_srv"),
	Child = {campfire_srv, {campfire_srv, start, []}, permanent, 2000, worker, [campfire_srv]},
	{ok, {{one_for_one, 1, 1}, [Child]}}.
