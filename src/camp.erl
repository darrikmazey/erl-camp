
-module(camp).
-compile(export_all).

-include_lib("wx/include/wx.hrl").

-define(ABOUT,?wxID_ABOUT).
-define(EXIT,?wxID_EXIT).

loop(Frame) ->
	receive
		#wx{id=?EXIT, event=#wxCommand{type=command_menu_selected}} ->
			wxWindow:close(Frame,[])
	end.

start() ->
	wx:new(),
	Frame = wxFrame:new(wx:null(), ?wxID_ANY, "camp"),
	%wxWindow:centerOnParent(Frame, [ {dir, ?wxVERTICAL bor ?wxHORIZONTAL} ]),
	setup(Frame),
	wxFrame:show(Frame),
	loop(Frame),
	wx:destroy().

setup(Frame) ->
	MenuBar = wxMenuBar:new(),
	File = wxMenu:new(),

	wxMenu:append(File,?EXIT, "exit"),

	wxMenuBar:append(MenuBar, File, "&File"),

	wxFrame:setMenuBar(Frame, MenuBar),
	
	wxFrame:createStatusBar(Frame),
	wxFrame:setStatusText(Frame, "camp initialized"),

	wxFrame:connect(Frame, command_menu_selected),
	wxFrame:connect(Frame, close_window).

