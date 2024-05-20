local mod = get_mod("DialoguePlayer")
local definitions = local_require("scripts/mods/DialoguePlayer/dialogue_player_definitions")
local widget_definitions = definitions.widgets
local scenegraph_definition = definitions.scenegraph_definition
local animation_definitions = definitions.animation_definitions

DialoguePlayerView = class(DialoguePlayerView)

function DialoguePlayerView:init(ingame_ui_context)
    self.ingame_ui_context = ingame_ui_context
    local input_manager = ingame_ui_context.input_manager
    input_manager:create_input_service("custom_view_name", "IngameMenuKeymaps", "IngameMenuFilters")
    input_manager:map_device_to_service("custom_view_name", "keyboard")
    input_manager:map_device_to_service("custom_view_name", "mouse")
    input_manager:map_device_to_service("custom_view_name", "gamepad")

    local world = Managers.world:world("level_world")
    self.wwise_world = Managers.world:wwise_world(world)

    self.input_manager = input_manager
    self.input_manager = input_manager
    self._ui_renderer = ingame_ui_context.ui_renderer
    self._ui_top_renderer = ingame_ui_context.ui_top_renderer
    self.voting_manager = ingame_ui_context.voting_manager

	self._render_settings = {
		snap_pixel_positions = true
	}

	self.filtered_dialogue_widgets = {}

end

function DialoguePlayerView:on_enter(transition_params)
    ShowCursorStack.push()
    local input_manager = self.input_manager
    input_manager:block_device_except_service("custom_view_name", "keyboard", 1)
    input_manager:block_device_except_service("custom_view_name", "mouse", 1)
    input_manager:block_device_except_service("custom_view_name", "gamepad", 1)

	self:play_sound("Play_hud_button_open")

    self:_create_ui_elements()
end

function DialoguePlayerView:on_exit()
	self.ui_animator = nil

	self.input_manager:device_unblock_all_services("keyboard", 1)
	self.input_manager:device_unblock_all_services("mouse", 1)
	self.input_manager:device_unblock_all_services("gamepad", 1)

	ShowCursorStack.pop()
end

function DialoguePlayerView:update(dt, t)
	self:update_filtered_dialogue()
	self:draw(self:input_service(), dt)

	if self:_has_active_level_vote() then
        mod:handle_transition("close_dialogue_player_view")
    else
        self:_handle_input(dt, t)
    end
end

function DialoguePlayerView:play_sound(event)
	WwiseWorld.trigger_event(self.wwise_world, event)
end

function DialoguePlayerView:input_service()
    return self.input_manager:get_service("custom_view_name")
end

DialoguePlayerView._has_active_level_vote = function (self)
    local voting_manager = self.voting_manager
    local active_vote_name = voting_manager:vote_in_progress()
    local is_mission_vote = active_vote_name == "game_settings_vote" or active_vote_name == "game_settings_deed_vote"

    return is_mission_vote and not voting_manager:has_voted(Network.peer_id())
end

DialoguePlayerView._create_ui_elements = function (self)
	self._ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
	local widgets = {}
	local widgets_by_name = {}

	for name, definition in pairs(widget_definitions) do
		local widget = UIWidget.init(definition)
		local num_widgets = #widgets
		widgets[num_widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	self._widgets = widgets
	self._widgets_by_name = widgets_by_name

	-- self:setup_sub_quest_display()
	-- self:_setup_modifier_list()

	-- self:setup_reward_display()

	UIRenderer.clear_scenegraph_queue(self._ui_renderer)

	self.ui_animator = UIAnimator:new(self._ui_scenegraph, animation_definitions)
end

DialoguePlayerView.draw = function (self, input_service, dt)
	local ui_renderer = self._ui_renderer
	local ui_top_renderer = self._ui_top_renderer
	local ui_scenegraph = self._ui_scenegraph
	local input_manager = self.input_manager
	local render_settings = self._render_settings
	local gamepad_active = input_manager:is_device_active("gamepad")

	local widgets = self._widgets

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

	for i,widget in pairs(widgets) do
		UIRenderer.draw_widget(ui_renderer, widget)
	end
	-- UIRenderer.draw_widget(ui_renderer, self._widgets[1])

	UIRenderer.end_pass(ui_renderer)

	render_settings.alpha_multiplier = alpha_multiplier

	if gamepad_active then
		self._menu_input_description:draw(ui_top_renderer, dt)
	end
end

DialoguePlayerView.post_update = function (self, dt, t)
	self.ui_animator:update(dt)
	self:_update_animations(dt)
end

DialoguePlayerView._update_animations = function (self, dt)
	local widgets_by_name = self._widgets_by_name
	local close_button = widgets_by_name.close_button

	UIWidgetUtils.animate_default_button(close_button, dt)
end

DialoguePlayerView._is_button_pressed = function (self, widget)
    local content = widget.content
    local hotspot = content.button_hotspot or content.hotspot
	if hotspot ~= nil then
		if hotspot.on_release then
			hotspot.on_release = false

			return true
		end
	end
end

DialoguePlayerView._is_button_hover_enter = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot or content.hotspot

	return hotspot.on_hover_enter
end

DialoguePlayerView._handle_input = function (self, dt, t)
	local esc_pressed = self:input_service():get("toggle_menu")
    local widgets = self._widgets
	local widgets_by_name = self._widgets_by_name

    if self:_is_button_pressed(widgets_by_name["close_button"]) then
		self:play_sound("Play_hud_select")
		mod:handle_transition("close_dialogue_player_view")
		return
    end

    if esc_pressed then

        mod:handle_transition("close_dialogue_player_view")

        return
    end
end

local title_text_style = {
	dynamic_height = false,
	upper_case = true,
	localize = false,
	word_wrap = false,
	font_size = 16,
	vertical_alignment = "center",
	horizontal_alignment = "center",
	use_shadow = true,
	dynamic_font_size = false,
	font_type = "hell_shark_header",
	text_color = Colors.get_color_table_with_alpha("font_title", 255),
	offset = {
		0,
		-150,
		2
	}
}
DialoguePlayerView.update_filtered_dialogue = function (self)
	self:clear_filtered_dialogue()

	local widgets = self._widgets
	local widgets_by_name = self._widgets_by_name

	local filtered_dialogue_widgets = self.filtered_dialogue_widgets

	local text_offset = 0
	for indx, dialogue_key in pairs(mod.found_dialogue) do
		local text_style = table.clone(title_text_style)
		text_style.offset[2] = text_offset
		text_offset = text_offset - (title_text_style.font_size + 3)
		local new_widget_def = UIWidgets.create_simple_text(indx.." : "..dialogue_key, "info_window_right_title_text", nil, nil, text_style)

		local widget = UIWidget.init(new_widget_def)
		local num_widgets = #widgets
		widgets[num_widgets + 1] = widget
		widgets_by_name[dialogue_key] = widget

		filtered_dialogue_widgets[dialogue_key] = {
			index = indx,
			widget_num = num_widgets + 1
		}
	end

end

DialoguePlayerView.clear_filtered_dialogue = function (self)
	local widgets = self._widgets
	local widgets_by_name = self._widgets_by_name

	local filtered_dialogue_widgets = self.filtered_dialogue_widgets

	for dialogue_key, data in pairs(filtered_dialogue_widgets) do
		widgets[data.widget_num] = nil
		widgets_by_name[dialogue_key] = nil
	end

	table.clear(self.filtered_dialogue_widgets)
end