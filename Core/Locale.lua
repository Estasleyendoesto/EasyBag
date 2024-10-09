local Locale = EasyBag:NewModule("Locale")

OPTIONS = {
    {selected = "ALL"},
    {selected = "RECENT"},
    {selected = "KEY"},
    {selected = "CHEST"},
    {selected = "QUEST"},
    {selected = "COLLECTIBLE"},
    {selected = "MATERIAL"},
    {selected = "ARMOR"},
    {selected = "WEAPON"},
    {selected = "ACCESORY"},
    {selected = "TRINKET"},
    {selected = "CONSUMABLE"},
    {selected = "RECIPE"}
}

function Locale:Translate()
    local lang = GetLocale()
    local tbl = LOCALIZATION[lang] or {}

    for i = 1, #tbl do
        if type(tbl[i]) == "table" then
            tbl[i].selected = OPTIONS[i].selected
        end
    end

    return tbl
end

function Locale:GetOption(selected)
    local translated_options = Locale:Translate()
    for _, option in ipairs(translated_options) do
        if option.selected == selected then
            return option
        end
    end
end