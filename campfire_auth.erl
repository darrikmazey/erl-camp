
%% campfire_auth.erl
%%
%% module to handle campfire authentication tuples

-module(campfire_auth).
-author(darrik_mazey).

-export([start/0]).
-export([stop/0]).
-export([request/1]).
-export([request/2]).
-export([request/3]).
-export([release/0]).
-export([find/1]).

-export([init/1]).

-include("include/campfire_auth.hrl").

start() ->
	case whereis(campfire_auth) of
		undefined ->
			register(campfire_auth, Pid = spawn(campfire_auth, init, [null]));
		Pid ->
			false
	end,
	Pid.

stop() ->
	campfire_auth ! #msg_campfire_auth_die{},
	true.

request(#campfire_auth{} = CA) ->
	io:format("request/1~n", []),
	campfire_auth ! #msg_campfire_auth_request{sender=self(), ca=CA},
	true.

request(Sub, User) ->
	io:format("request/2~n", []),
	CA = #campfire_auth{subdomain=Sub, username=User},
	request(CA).

request(Sub, User, Pass) ->
	io:format("request/3~n", []),
	CA = #campfire_auth{subdomain=Sub, username=User, password=Pass},
	request(CA).

release() ->
	campfire_auth ! #msg_campfire_auth_drop{sender=self()},
	true.

find(P) ->
	campfire_auth ! #msg_campfire_auth_find{sender=self(), p=P},
	CAsrv = whereis(campfire_auth),
	receive
		#msg_campfire_auth_res{sender=CAsrv, p=P, ca=CA} -> CA;
		#msg_campfire_auth_res{sender=CAsrv, p=P, ca=null} -> {ok, notfound}
	end.

init(null) ->
	loop([]);
init(State) ->
	loop(State).

loop(State) ->
	receive
		#msg_campfire_auth_die{} -> true;
		#msg_campfire_auth_request{sender=Sender, ca=#campfire_auth{subdomain=_Subdomain, username=_Username, password=_Password} = CA} ->
			%io:format("auth request received from ~p for { ~p, ~p, ~p }~n", [Sender, Subdomain, Username, Password]),
			io:format("auth request received from ~p for ~p~n", [Sender, CA]),
			NewState = store({Sender, CA}, State),
			io:format("new state: ~p~n", [NewState]),
			loop(NewState);
		#msg_campfire_auth_drop{sender=Sender, ca=CA} ->
			io:format("drop request received from ~p~n", [Sender]),
			NewState = drop({Sender, CA}, State),
			io:format("new state: ~p~n", [NewState]),
			loop(NewState);
		#msg_campfire_auth_find{sender=Sender, p=P} ->
			io:format("find request received from ~p for ~p~n", [Sender, P]),
			Sender ! #msg_campfire_auth_res{sender=self(), p=P, ca=retr(P, State)},
			loop(State);
		_ -> loop(State)
	end.

store({Sender, CA}, [{Sender, _}|T]) -> [{Sender, CA}|T];
store(Tuple, [H|T]) -> [H|store(Tuple, T)];
store(Tuple, []) -> [Tuple|[]].

drop({Sender, _CA}, [{Sender, _}|T]) -> T;
drop(Tuple, [H|T]) -> [H|drop(Tuple, T)];
drop(_Tuple, []) -> [].

retr(P, [{P, CA}|_T]) -> CA;
retr(P, [_H|T]) -> retr(P, T);
retr(_P, []) -> null.
