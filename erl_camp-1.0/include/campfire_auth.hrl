
%% campfire auth
-record(campfire_auth, { subdomain, username, password = "X" }).

%% campfire auth die request
-record(msg_campfire_auth_die, { sender, why }).

%% campfire auth request
-record(msg_campfire_auth_request, { sender, ca }).

%% campfire auth drop request
-record(msg_campfire_auth_drop, { sender, ca = null }).

%% campfire auth find request
-record(msg_campfire_auth_find, { sender, p }).

%% campfire auth find result
-record(msg_campfire_auth_res, { sender, p, ca }).
