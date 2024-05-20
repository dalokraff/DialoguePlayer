local mod = get_mod("DialoguePlayer")

local menu = {
	name = "DialoguePlayer",
	description = mod:localize("mod_description"),
	is_togglable = true,
}

menu.options = {}
menu.options.widgets = {
	{
        setting_id = "dialogue_player_view",
        type = "keybind",
        keybind_type = "view_toggle",
		keybind_trigger = "pressed",
		default_value = {},
        view_name = "dialogue_player_view",
        transition_data = {
			open_view_transition_name = "open_dialogue_player_view",
			close_view_transition_name = "close_dialogue_player_view",
			transition_fade = true
        },
		{
			keybind_global = true,
			keybind_trigger = "pressed",
			setting_id = "next_dialogue",
			type = "keybind",
			keybind_type = "function_call",
			function_name = "next",
			default_value = {}
		},
		{
			keybind_global = true,
			keybind_trigger = "pressed",
			setting_id = "previous_dialogue",
			type = "keybind",
			keybind_type = "function_call",
			function_name = "prev",
			default_value = {}
		},
		{
			keybind_global = true,
			keybind_trigger = "pressed",
			setting_id = "play_dialogue",
			type = "keybind",
			keybind_type = "function_call",
			function_name = "play_dialogue",
			default_value = {}
		}
	}
}

return menu