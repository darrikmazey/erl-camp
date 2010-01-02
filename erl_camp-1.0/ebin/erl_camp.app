{application, erl_camp,
	[{description, "erlang campfire client"},
	 {vsn, "1.0"},
	 {modules, [campfire_client, campfire_auth, erl_camp]},
	 {registered, [campfire_client, campfire_auth]},
	 {applications, [kernel, stdlib]},
	 {env, []},
	 {mod, {erl_camp, []}}]}.
