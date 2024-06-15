local dialogue = {}
local dialgoue_localized = {}
local selected_dialogue = 0

local getAllDialogue = function()
    for key,value in pairs(DialogueLookup) do
        if string.match(key,"[a-zA-Z]") then
            table.insert( dialogue, key )
            dialgoue_localized[key] = Localize(key)
        end
    end

    table.sort(dialogue)
end

getAllDialogue()

return {
    dialgoue_localized = dialgoue_localized,
    dialogue = dialogue,
}