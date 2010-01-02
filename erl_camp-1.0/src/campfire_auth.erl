
%% campfire_auth.erl
%%
%% module to handle campfire authentication tuples

-module(campfire_auth).
-author(darrik@darmasoft.com).

-export([start/0]).
-export([stop/0]).
-export([login/1]).
-export([login/2]).
-export([login/3]).
-export([logout/0]).
-export([find/1]).

-export([init/0]).

-include("include/campfire_auth.hrl").

start() ->
	case whereis(campfire_auth) of
		undefined ->
			register(campfire_auth, Pid = spawn_link(campfire_auth, init, []));
		Pid ->
			false
	end,
	{ok, Pid}.

stop() ->
	campfire_auth ! #msg_campfire_auth_die{},
	true.

login(#campfire_auth{} = CA) ->
	start(),
	campfire_auth ! #msg_campfire_auth_request{sender=self(), ca=CA},
	CA.

login(Sub, User) ->
	CA = #campfire_auth{subdomain=Sub, username=User},
	login(CA).

login(Sub, User, Pass) ->
	CA = #campfire_auth{subdomain=Sub, username=User, password=Pass},
	login(CA).

logout() ->
	campfire_auth ! #msg_campfire_auth_drop{sender=self()},
	true.

find(P) ->
	CAsrv = whereis(campfire_auth),
	Ret = case CAsrv of
		undefined ->
			{error, noserver};
		Pid ->
			campfire_auth ! #msg_campfire_auth_find{sender=self(), p=P},
			receive
				#msg_campfire_auth_res{sender=Pid, p=P, ca=null} -> {ok, notfound};
				#msg_campfire_auth_res{sender=Pid, p=P, ca=CA} -> CA
			end
	end,
	Ret.

init() ->
	loop([]).

loop(State) ->
	receive
		#msg_campfire_auth_die{} -> true;
		#msg_campfire_auth_request{sender=Sender, ca=#campfire_auth{subdomain=_Subdomain, username=_Username, password=_Password} = CA} ->
			NewState = store({Sender, CA}, State),
			loop(NewState);
		#msg_campfire_auth_drop{sender=Sender, ca=CA} ->
			NewState = drop({Sender, CA}, State),
			loop(NewState);
		#msg_campfire_auth_find{sender=Sender, p=P} ->
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
