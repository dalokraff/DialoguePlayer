local mod = get_mod("DialoguePlayer")
local dialogue = {}
local selected_dialogue = 0



mod.getAllDialogue = function()
    for key,value in pairs(DialogueLookup) do
        if string.match(key,"[a-zA-Z]") then
            table.insert( dialogue, key )
        end
    end

    table.sort(dialogue)
end

mod.getAllDialogue()


---------------------
-- Chat Commands
---------------------

-- mod:command("dialogueFilterByKey", " enter key to search", function(searchKey)
--     if not searchKey then
--         mod:echo("ERROR: Please pass in an arg to search. Example:\n/dialogueFilterByKey pwh")
--         return
--     end

--     selected_dialogue = 0
--     table.clear(dialogue)

--     for key,value in pairs(DialogueLookup) do
--         if string.match(key,"[a-zA-Z]") and string.find( string.lower(key), string.lower(searchKey) )then
--             table.insert( dialogue, key )
--         end
--     end
-- end)

-- mod:command("dialogueFilterByWord", " Enter the words in the localized text you are looking for", function(words)
--     if not words then
--         mod:echo("ERROR: Please pass in an arg to search. Example:\n/dialogueFilterByWord elf")
--         return
--     end

--     selected_dialogue = 0
--     table.clear(dialogue)
--     for key,value in pairs(DialogueLookup) do
--         if string.match(key,"[a-zA-Z]") and string.find( string.lower(Localize(key)), string.lower(words) )then
--             table.insert( dialogue, key )
--         end
--     end
-- end)

-- mod:command("dialogueClearFilter", " Clears searches", function()
--     selected_dialogue = 0
--     table.clear(dialogue)
--     mod.getAllDialogue()
-- end)

mod.found_dialogue = {}
mod:command("search_dialogue", "search for dialgoue by it's unlocalized dialogue key", function(search_string, is_loaded_filter)
    table.clear(mod.found_dialogue)
    for idx,diag_key in ipairs(dialogue) do
        if string.find(diag_key, search_string) then
            local is_loaded = Wwise.has_event(diag_key)
            if is_loaded_filter == nil then
                mod:info(idx.." : "..diag_key)
                mod.found_dialogue[idx] = diag_key
            elseif (tonumber(is_loaded_filter)~=0) == is_loaded then
                mod:info(idx.." : "..diag_key)
                mod.found_dialogue[idx] = diag_key
            end
        end
    end
    mod.update_dialogue_menu = true
end)

mod:command("pause_sounds", "Pauses all currently playing sounds in the world", function()
    local world = Managers.world:world("level_world")
    local wwise_world = Managers.world:wwise_world(world)
    WwiseWorld.pause_all(wwise_world)
    mod:echo("All sounds paused")
end)

mod:command("resume_sounds", "Resumes all currently playing sounds in the world", function()
    local world = Managers.world:world("level_world")
    local wwise_world = Managers.world:wwise_world(world)
    WwiseWorld.resume_all(wwise_world)
    mod:echo("All sounds resumed")
end)

mod:command("play_dialogue_by_index", "pass in a number, to play a piece of dialogue by it's mod-dialogue index", function(index)
    local world = Managers.world:world("level_world")
    local wwise_world = Managers.world:wwise_world(world)
    local event = dialogue[index + 1]
    local ok = WwiseWorld.trigger_event(wwise_world, event)
    mod:echo("\nPlaying: %q \nLocalize: \"%s\"", event, Localize(event))
end)

------------------
--  Key Binding
------------------

mod.next = function()
    selected_dialogue = (selected_dialogue + 1) % #dialogue
    mod:echo(dialogue[selected_dialogue + 1])
end

mod.prev = function()
    selected_dialogue = (selected_dialogue - 1) % #dialogue
    mod:echo(dialogue[selected_dialogue + 1])
end

mod.play_dialogue = function()
    local world = Managers.world:world("level_world")
    local wwise_world = Managers.world:wwise_world(world)
    local event = dialogue[selected_dialogue + 1]
    local ok = WwiseWorld.trigger_event(wwise_world, event)
    mod:echo("\nPlaying: %q \nLocalize: \"%s\"", event, Localize(event))
end



mod:dofile("scripts/mods/DialoguePlayer/dialogue_player_view")
local letter_view_data = {
    view_name = "dialogue_player_view",
    view_settings = {
      init_view_function = function(ingame_ui_context)
        return DialoguePlayerView:new(ingame_ui_context)
      end,
      active = {        -- Only enable in keep
        inn = true,
        ingame = false
      },
      blocked_transitions = {
        inn = {},
        ingame = {}
      }
    },
    view_transitions = {
      open_dialogue_player_view = function(ingame_ui)
        ingame_ui.current_view = "dialogue_player_view"
      end,
      close_dialogue_player_view = function(ingame_ui)
        ingame_ui.current_view = nil
      end
    }
  }
mod:register_view(letter_view_data)

-- Your mod code goes here.
-- https://vmf-docs.verminti.de

-- mod:echo(Managers.ui._ingame_ui_context.ui_renderer)
-- for k,v in pairs(Gui) do
--     print(k,v)
-- end
