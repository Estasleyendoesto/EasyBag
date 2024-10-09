local Events = EasyBag:NewModule("Events", "AceEvent-3.0")

function Events:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEnteringWorld")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnNewArea")
    self:RegisterEvent("BAG_UPDATE", "OnBagUpdate")
    self:RegisterEvent("BAG_UPDATE_DELAYED", "OnBagUpdateDelayed")
    self:RegisterEvent("CHAT_MSG_LOOT", "OnLoot")

    -- Detector de apertura / cierre de bolsas
    hooksecurefunc("ToggleAllBags", function()
        Events:SendMessage("SET_REVEAL_ALL")
        Events:SendMessage("HIDE_RESET_BUTTON")
        EasyBag.selectedOption = nil
    end)

    -- Desactiva el filtro al usar el buscador
    if BagItemSearchBox then
        BagItemSearchBox:HookScript("OnTextChanged", function()
            Events:SendMessage("SET_REVEAL_ALL")
            Events:SendMessage("HIDE_RESET_BUTTON")
            EasyBag.selectedOption = nil
        end)
    end
end

function Events:OnEnteringWorld()
    EasyBag.recentLoot = {}
	self:SendMessage("SET_REVEAL_ALL")
end

function Events:OnNewArea()
    EasyBag.recentLoot = {}
end

function Events:OnBagUpdate()
    self:SendMessage("REFRESH_FILTER")
end

function Events:OnBagUpdateDelayed()
    self:SendMessage("REFRESH_FILTER")
end

function Events:OnLoot(ev, ...)
    local text = ...
    local itemLink = string.match(text, "|c%x+|Hitem:.-|h.-|h|r")
    if itemLink then
        local itemID = string.match(itemLink, "Hitem:(%d+)")
        table.insert(EasyBag.recentLoot, {itemID, GetItemInfo(itemLink)})
    end
end