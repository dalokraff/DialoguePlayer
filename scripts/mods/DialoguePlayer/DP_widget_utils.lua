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

return DPWidgetUtils