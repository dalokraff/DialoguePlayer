local mod = get_mod("DialoguePlayer")
local DPWidgetUtils = local_require("scripts/mods/DialoguePlayer/DP_widget_utils")
local definitions = local_require("scripts/mods/DialoguePlayer/dialogue_player_definitions")
local widget_definitions = definitions.widgets
local scenegraph_definition = definitions.scenegraph_definition
local animation_definitions = definitions.animation_definitions
local search_widget_definitions = definitions.search_widget_definitions

local dialgoue_tables = local_require("scripts/mods/DialoguePlayer/dialogue_tables")
local dialgoue_localized = dialgoue_tables.dialgoue_localized
local dialogue = dialgoue_tables.dialogue

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

	self.widgets = {}
	self.widgets_by_name = {}
	self.widgets_to_animate = {}

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
	self.widgets_to_animate = {}

	for name, definition in pairs(widget_definitions) do
		local widget = UIWidget.init(definition)
		local num_widgets = #widgets
		widgets[num_widgets + 1] = widget
		widgets_by_name[name] = widget
	end

	self._widgets = widgets
	self._widgets_by_name = widgets_by_name

	self._search_widgets, self._search_widgets_by_name = UIUtils.create_widgets(search_widget_definitions)

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

	UIRenderer.draw_all_widgets(ui_renderer, self._search_widgets)

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

	for k,widget in pairs(self.widgets_to_animate) do
		UIWidgetUtils.animate_default_button(widget, dt)
	end
end

DialoguePlayerView._is_button_pressed = function (self, widget)
    if widget then
		local content = widget.content
		local hotspot = content.button_hotspot or content.hotspot
		if hotspot ~= nil then
			if hotspot.on_release then
				hotspot.on_release = false

				return true
			end
		end
	end
end

DialoguePlayerView._is_button_hover_enter = function (self, widget)
	local content = widget.content
	local hotspot = content.button_hotspot or content.hotspot

	return hotspot.on_hover_enter
end

DialoguePlayerView._do_search = function (self, search_query)
	table.clear(mod.found_dialogue)
    local counter = 0
    for diag_key,local_diag in pairs(dialgoue_localized) do
        if string.find(local_diag, search_query) then
            local is_loaded = Wwise.has_event(diag_key)
            if is_loaded_filter == nil then
                mod:info(diag_key.." : "..local_diag)
                mod.found_dialogue[counter] = diag_key
                counter = counter + 1
            elseif (tonumber(is_loaded_filter)~=0) == is_loaded then
                mod:info(diag_key.." : "..local_diag)
                mod.found_dialogue[counter] = diag_key
                counter = counter + 1
            end
        end
    end
    mod.update_dialogue_menu = true
	self:play_sound("Play_hud_select")
end

DialoguePlayerView._set_input_blocked = function (self, blocked)
	local input_manager = Managers.input

	if blocked then
		input_manager:block_device_except_service("hero_view", "keyboard", 1, "search")
		input_manager:block_device_except_service("hero_view", "mouse", 1, "search")
		input_manager:block_device_except_service("hero_view", "gamepad", 1, "search")
	else
		input_manager:device_unblock_all_services("keyboard")
		input_manager:device_unblock_all_services("mouse")
		input_manager:device_unblock_all_services("gamepad")
		input_manager:block_device_except_service("hero_view", "keyboard", 1)
		input_manager:block_device_except_service("hero_view", "mouse", 1)
		input_manager:block_device_except_service("hero_view", "gamepad", 1)
	end

	-- self.parent:set_input_blocked(blocked)
end

DialoguePlayerView._handle_search_input = function (self, dt, t, input_service)
	local input_content = self._search_widgets_by_name.input.content
	-- local filters_content = self._search_widgets_by_name.filters.content

	-- if input_content.clear_hotspot.on_pressed then
	-- 	input_content.search_query, input_content.caret_index, input_content.text_index = "", 1, 1

	-- 	self:_do_search(input_content.search_query)

	-- 	return true
	-- end

	-- if filters_content.query_dirty then
	-- 	self:_do_search(input_content.search_query)

	-- 	filters_content.query_dirty = false
	-- end

	-- local do_toggle = input_content.search_filters_hotspot.on_pressed

	-- if filters_content.visible and (input_service:get("toggle_menu", true) or input_service:get("back", true)) then
	-- 	do_toggle = true
	-- end

	-- if do_toggle then
	-- 	local filters_active = not filters_content.visible

	-- 	filters_content.visible = filters_active
	-- 	input_content.filters_active = filters_active

	-- 	return false
	-- end

	-- if input_service:get("special_1") and self._achievement_layout_type ~= "summary" and not table.is_empty(filters_content.query) then
	-- 	table.clear(filters_content.query)
	-- 	self:_do_search(input_content.search_query)
	-- end

	-- if not self._keyboard_id then
	-- 	input_content.input_active = false

	-- 	if input_content.hotspot.on_pressed then
	-- 		input_content.input_active = true

	-- 		if IS_WINDOWS then
	-- 			self:_set_input_blocked(true)

	-- 			self._keyboard_id = true
	-- 		elseif IS_XB1 then
	-- 			local title = Localize("lb_search")

	-- 			XboxInterface.show_virtual_keyboard(self._search_query, title)

	-- 			self._keyboard_id = true
	-- 		elseif IS_PS4 then
	-- 			local user_id = Managers.account:user_id()
	-- 			local title = Localize("lb_search")
	-- 			local position = definitions.virtual_keyboard_anchor_point

	-- 			self._keyboard_id = Managers.system_dialog:open_virtual_keyboard(user_id, title, self._search_query, position)
	-- 		end

	-- 		return true
	-- 	end

	-- 	-- return filters_content.visible
	-- 	return nil
	-- end

	Managers.chat:block_chat_input_for_one_frame()

	local keystrokes = Keyboard.keystrokes()

	input_content.search_query, input_content.caret_index = KeystrokeHelper.parse_strokes(input_content.search_query, input_content.caret_index, "insert", keystrokes)

	if self:input_service():get("execute_chat_input", true) then
		self:_do_search(input_content.search_query)
		-- self:_set_input_blocked(false)

		input_content.input_active = false
		self._keyboard_id = nil
	elseif self:input_service():get("toggle_menu", true) or self:input_service():get("back", true) then
		self:_set_input_blocked(false)

		input_content.input_active = false
		self._keyboard_id = nil
	end


	if input_content.hotspot.on_pressed then
		return true
	end

	-- return filters_content.visible
	return nil
end

DialoguePlayerView._handle_input = function (self, dt, t)
	local esc_pressed = self:input_service():get("toggle_menu")
    local widgets = self._widgets
	local widgets_by_name = self._widgets_by_name
	local filtered_dialogue_widgets = self.filtered_dialogue_widgets

	local input_service = self._input_blocked or self:input_service()

	if self:_handle_search_input(dt, t, input_service) then
		return
	end

    if self:_is_button_pressed(widgets_by_name["close_button"]) then
		self:play_sound("Play_hud_select")
		mod:handle_transition("close_dialogue_player_view")
		return
    end

	for dialogue_key,data in pairs (filtered_dialogue_widgets) do
		local widget = widgets_by_name[dialogue_key]
		if self:_is_button_pressed(widget) then
			self:play_sound(dialogue_key)
			return
		end
	end


    if esc_pressed then

        mod:handle_transition("close_dialogue_player_view")

        return
    end
end

local font_size = 16
DialoguePlayerView.update_filtered_dialogue = function (self)
	if mod.update_dialogue_menu then
		self:clear_filtered_dialogue()

		local widgets = self._widgets
		local widgets_by_name = self._widgets_by_name
		local widgets_to_animate = self.widgets_to_animate

		local filtered_dialogue_widgets = self.filtered_dialogue_widgets

		local text_offset = 0
		for indx, dialogue_key in pairs(mod.found_dialogue) do
			local offset = {
				0,
				-25 + text_offset,
				2
			}
			text_offset = text_offset - (font_size + 3)
			-- local new_widget_def = UIWidgets.create_text_button("info_window_right_title_text", indx.." : "..dialogue_key, font_size, offset)
			local new_widget_def = DPWidgetUtils.create_simple_window_button("info_window_right_title_text", nil, dialogue_key.." : "..Localize(dialogue_key), font_size, nil, nil, offset)

			local widget = UIWidget.init(new_widget_def)
			local num_widgets = #widgets
			local num_widgets_to_animate = #widgets_to_animate
			widgets[num_widgets + 1] = widget
			widgets_by_name[dialogue_key] = widget
			widgets_to_animate[num_widgets_to_animate + 1] = widget

			filtered_dialogue_widgets[dialogue_key] = {
				index = indx,
				widget_num = num_widgets + 1
			}
		end

		mod.update_dialogue_menu = false
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