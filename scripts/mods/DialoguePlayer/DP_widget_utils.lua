DPWidgetUtils = {}

DPWidgetUtils.create_simple_window_button = function (scenegraph_id, size, text, font_size, background_texture, hover_glow_texture, optional_offset)
	background_texture = background_texture or "button_bg_01"
	local background_texture_settings = UIAtlasHelper.get_atlas_settings_by_texture_name(background_texture)

	local clicked_rect_offset = optional_offset or {0,0,0}
	clicked_rect_offset[3] = clicked_rect_offset[3] + 7

	local title_text_offset = optional_offset or {0,0,0}
	title_text_offset[2] = title_text_offset[2] + 3
	title_text_offset[3] = title_text_offset[3] + 6

	local title_text_disabled = optional_offset or {0,0,0}
	title_text_disabled[2] = title_text_disabled[2] + 3
	title_text_disabled[3] = title_text_disabled[3] + 6

	local title_text_shadow_disabled = optional_offset or {0,0,0}
	title_text_shadow_disabled[1] = title_text_shadow_disabled[1] + 2
	title_text_shadow_disabled[2] = title_text_shadow_disabled[2] + 1
	title_text_shadow_disabled[3] = title_text_shadow_disabled[3] + 7

	return {
		element = {
			passes = {
				{
					style_id = "background",
					pass_type = "hotspot",
					content_id = "button_hotspot"
				},
				-- {
				-- 	texture_id = "hover_glow",
				-- 	style_id = "hover_glow",
				-- 	pass_type = "texture",
				-- 	content_check_function = function (content)
				-- 		local button_hotspot = content.button_hotspot

				-- 		return not button_hotspot.disable_button and (button_hotspot.is_selected or button_hotspot.is_hover)
				-- 	end
				-- },
				{
					style_id = "title_text",
					pass_type = "text",
					text_id = "title_text",
					content_check_function = function (content)
						local button_hotspot = content.button_hotspot

						return not button_hotspot.disable_button
					end
				},
				{
					style_id = "title_text_disabled",
					pass_type = "text",
					text_id = "title_text",
					content_check_function = function (content)
						local button_hotspot = content.button_hotspot

						return button_hotspot.disable_button
					end
				},
				{
					style_id = "title_text_shadow",
					pass_type = "text",
					text_id = "title_text"
				},
				-- {
				-- 	texture_id = "glass",
				-- 	style_id = "glass_top",
				-- 	pass_type = "texture"
				-- },
				-- {
				-- 	texture_id = "glass",
				-- 	style_id = "glass_bottom",
				-- 	pass_type = "texture"
				-- }
			}
		},
		content = {
			-- glass = "button_glass_02",
			-- hover_glow = hover_glow_texture, --"la_ui_closebutton_active",
			-- background_fade = "button_bg_fade",
			button_hotspot = {},
			title_text = text or "n/a",
			background = {
				-- uvs = {
				-- 	{
				-- 		0,
				-- 		1 - size[2] / background_texture_settings.size[2]
				-- 	},
				-- 	{
				-- 		size[1] / background_texture_settings.size[1],
				-- 		1
				-- 	}
				-- },
				texture_id = background_texture
			}
		},
		style = {
			background = {
				color = {
					255,
					255,
					255,
					255
				},
				offset = optional_offset or {
					0,
					0,
					0
				}
			},
			-- hover_glow = {
			-- 	texture_size = {
			-- 		426,
			-- 		44
			-- 	},
			-- 	offset = {
			-- 		0,
			-- 		0,
			-- 		32
			-- 	},
			-- 	-- size = {
			-- 	-- 	size[1],
			-- 	-- 	math.min(size[2] - 5, 80)
			-- 	-- }
			-- },
			clicked_rect = {
				color = Colors.get_color_table_with_alpha("orange", 100),
				offset = clicked_rect_offset,
			},
			title_text = {
				upper_case = true,
				word_wrap = false,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				font_type = "hell_shark_header",
				font_size = font_size or 24,
				text_color = Colors.get_color_table_with_alpha("font_title", 255),
				default_text_color = Colors.get_color_table_with_alpha("font_title", 255),
				disabled_default_text_color = Colors.get_color_table_with_alpha("font_title", 255),
				select_text_color = Colors.get_color_table_with_alpha("white", 255),
				offset = title_text_offset,
			},
			title_text_disabled = {
				upper_case = true,
				word_wrap = false,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				font_type = "hell_shark_header",
				font_size = font_size or 24,
				text_color = Colors.get_color_table_with_alpha("yellow", 255),
				disabled_default_text_color = Colors.get_color_table_with_alpha("yellow", 255),
				default_text_color = Colors.get_color_table_with_alpha("yellow", 255),
				offset = title_text_disabled,
			},
			title_text_shadow = {
				upper_case = true,
				word_wrap = false,
				horizontal_alignment = "center",
				vertical_alignment = "center",
				font_type = "hell_shark_header",
				font_size = font_size or 24,
				text_color = Colors.get_color_table_with_alpha("font_title", 255),
				disabled_default_text_color = Colors.get_color_table_with_alpha("font_title", 255),
				default_text_color = Colors.get_color_table_with_alpha("font_title", 255),
				offset = title_text_shadow_disabled,
			},
		},
		scenegraph_id = scenegraph_id,
		offset = optional_offset or {
			0,
			0,
			0
		}
	}
end

DPWidgetUtils.create_search_input_widget = function(scenegraph_id, size)
	local frame_settings = UIFrameSettings.button_frame_01
	local glow_settings = UIFrameSettings.frame_outer_glow_01
	local glow_width = glow_settings.texture_sizes.horizontal[2]

	return {
		scenegraph_id = scenegraph_id,
		offset = {
			0,
			0,
			0,
		},
		element = {
			passes = {
				{
					content_id = "hotspot",
					pass_type = "hotspot",
				},
				{
					pass_type = "texture",
					style_id = "bg_texture",
					texture_id = "bg_texture",
				},
				{
					pass_type = "texture_frame",
					style_id = "frame",
					texture_id = "frame",
				},
				{
					content_id = "details",
					pass_type = "texture",
					style_id = "detail_left",
				},
				{
					content_id = "details",
					pass_type = "texture_uv",
					style_id = "detail_right",
				},
				{
					pass_type = "texture_frame",
					style_id = "glow",
					texture_id = "glow",
					content_change_function = function (content, style)
						if content.input_active then
							style.color[1] = 255
						elseif content.hotspot.is_hover then
							style.color[1] = 100
						else
							style.color[1] = 0
						end
					end,
				},
				{
					pass_type = "text",
					style_id = "search_placeholder",
					text_id = "search_placeholder",
					content_check_function = function (content)
						return content.search_query == "" and not content.input_active
					end,
				},
				{
					pass_type = "text",
					style_id = "search_query",
					text_id = "search_query",
					content_change_function = function (content, style)
						if not content.input_active then
							style.caret_color[1] = 0
						else
							style.caret_color[1] = 127 + 128 * math.sin(5 * Managers.time:time("ui"))
						end
					end,
				},
				{
					content_id = "search_filters_hotspot",
					pass_type = "hotspot",
					style_id = "search_filters_hotspot",
					content_check_function = function ()
						return not Managers.input:is_device_active("gamepad")
					end,
					content_change_function = function (content, style)
						local filters_active = content.parent.filters_active

						if filters_active ~= content.filters_active then
							content.filters_active = filters_active

							if filters_active then
								Colors.copy_to(style.parent.search_filters_glow.color, Colors.color_definitions.white)
							else
								Colors.copy_to(style.parent.search_filters_glow.color, Colors.color_definitions.font_title)
							end
						end

						local alpha = 0

						if content.is_hover then
							alpha = 255
						elseif content.filters_active then
							alpha = 200
						end

						style.parent.search_filters_glow.color[1] = alpha
					end,
				},
				{
					pass_type = "texture",
					style_id = "search_filters_bg",
					texture_id = "search_filters_bg",
				},
				{
					pass_type = "texture",
					style_id = "search_filters_icon",
					texture_id = "search_filters_icon",
				},
				{
					pass_type = "texture",
					style_id = "search_filters_glow",
					texture_id = "search_filters_glow",
				},
				{
					content_id = "clear_hotspot",
					pass_type = "hotspot",
					style_id = "clear_icon",
				},
				{
					pass_type = "texture",
					style_id = "clear_icon",
					texture_id = "clear_icon",
					content_check_function = function (content)
						return content.search_query ~= ""
					end,
					content_change_function = function (content, style)
						local clear_hotspot = content.clear_hotspot
						local is_hover = clear_hotspot.is_hover

						if is_hover ~= clear_hotspot.was_hover then
							clear_hotspot.was_hover = is_hover

							if is_hover then
								Colors.copy_to(style.color, Colors.color_definitions.font_title)
							else
								Colors.copy_to(style.color, Colors.color_definitions.very_dark_gray)
							end
						end
					end,
				},
			},
		},
		content = {
			bg_texture = "search_bar_texture",
			caret_index = 1,
			clear_icon = "friends_icon_close",
			input_active = false,
			search_filters_bg = "search_filters_bg",
			search_filters_glow = "search_filters_icon_glow",
			search_filters_icon = "search_filters_icon",
			search_placeholder = "achievement_search_prompt",
			search_query = "",
			text_index = 1,
			hotspot = {
				allow_multi_hover = true,
			},
			frame = frame_settings.texture,
			glow = glow_settings.texture,
			details = {
				texture_id = "button_detail_04",
				uvs = {
					{
						1,
						0,
					},
					{
						0,
						1,
					},
				},
			},
			search_filters_hotspot = {},
			clear_hotspot = {},
		},
		style = {
			bg_texture = {
				color = {
					255,
					200,
					200,
					200,
				},
				offset = {
					0,
					0,
					0,
				},
			},
			frame = {
				texture_size = frame_settings.texture_size,
				texture_sizes = frame_settings.texture_sizes,
				offset = {
					0,
					0,
					2,
				},
				color = {
					255,
					255,
					255,
					255,
				},
			},
			detail_left = {
				horizontal_alignment = "left",
				offset = {
					-34,
					0,
					3,
				},
				texture_size = {
					60,
					42,
				},
			},
			detail_right = {
				horizontal_alignment = "right",
				offset = {
					34,
					0,
					3,
				},
				texture_size = {
					60,
					42,
				},
			},
			glow = {
				frame_margins = {
					-glow_width,
					-glow_width,
				},
				texture_size = glow_settings.texture_size,
				texture_sizes = glow_settings.texture_sizes,
				offset = {
					0,
					0,
					3,
				},
				color = {
					255,
					255,
					255,
					255,
				},
			},
			search_placeholder = {
				dynamic_font = true,
				font_size = 25,
				font_type = "hell_shark_header",
				horizontal_alignment = "left",
				localize = true,
				pixel_perfect = true,
				vertical_alignment = "center",
				text_color = {
					255,
					25,
					25,
					25,
				},
				offset = {
					47,
					-3,
					5,
				},
			},
			search_query = {
				dynamic_font = true,
				font_size = 25,
				font_type = "hell_shark_header",
				horizontal_alignment = "left",
				horizontal_scroll = true,
				pixel_perfect = true,
				vertical_alignment = "center",
				word_wrap = false,
				text_color = Colors.get_table("black"),
				offset = {
					47,
					13,
					3,
				},
				caret_size = {
					2,
					26,
				},
				caret_offset = {
					0,
					-6,
					6,
				},
				caret_color = Colors.get_table("black"),
				size = {
					size[1] - 90,
					size[2],
				},
			},
			search_filters_hotspot = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				area_size = {
					96,
					96,
				},
				offset = {
					-42,
					28,
					7,
				},
			},
			search_filters_bg = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				color = {
					255,
					255,
					255,
					255,
				},
				texture_size = {
					128,
					128,
				},
				offset = {
					-80,
					-4,
					8,
				},
			},
			search_filters_icon = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				color = Colors.get_color_table_with_alpha("white", 255),
				texture_size = {
					128,
					128,
				},
				offset = {
					-80,
					-4,
					8,
				},
			},
			search_filters_glow = {
				horizontal_alignment = "left",
				vertical_alignment = "center",
				color = Colors.get_color_table_with_alpha("font_title", 255),
				texture_size = {
					128,
					128,
				},
				offset = {
					-80,
					-4,
					9,
				},
			},
			clear_icon = {
				horizontal_alignment = "right",
				vertical_alignment = "center",
				color = {
					255,
					80,
					80,
					80,
				},
				texture_size = {
					32,
					32,
				},
				area_size = {
					32,
					32,
				},
				offset = {
					-15,
					0,
					7,
				},
			},
			help_tooltip = {
				cursor_side = "right",
				draw_downwards = true,
				font_size = 18,
				font_type = "hell_shark",
				horizontal_alignment = "left",
				localize = false,
				max_width = 1500,
				vertical_alignment = "center",
				text_color = Colors.get_table("white"),
				line_colors = {
					Colors.get_table("orange_red"),
				},
				cursor_offset = {
					0,
					30,
				},
				offset = {
					0,
					0,
					50,
				},
				area_size = {
					45,
					45,
				},
			},
		},
	}
end

return DPWidgetUtils