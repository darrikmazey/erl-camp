
%% campfire_client.erl
%%
%% campfire client

-module(campfire_client).
-author(darrik@darmasoft.com).

-export([start/0]).
-export([stop/0]).
-export([init/0]).

-include("include/campfire_client.hrl").

start() ->
	register(campfire_client, Pid =  spawn(campfire_client, init, [])),
	Pid.

stop() ->
	campfire_client ! #msg_campfire_client_die{sender=self()},
	true.

init() ->
	campfire_auth:login(test:darma()),
	loop([]).

loop(State) ->
	receive
		#msg_campfire_client_die{} ->
			campfire_auth:logout(),
			unregister(campfire_client),
			true;
		_ -> loop(State)
	end.

