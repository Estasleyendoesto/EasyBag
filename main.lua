--[[
    EasyBag Addon
    Version: 0.1 (07/09/2024)
    Author: EEsto
    It simplifies inventory management, allowing players to easily filter and locate items within their bags by category.
]]

EasyBag.OPTIONS = {
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

function EasyBag:Translate()
    local lang = GetLocale()
    local tbl = EasyBag.LOCALIZATION[lang] or {}

    for i = 1, #tbl do
        if type(tbl[i]) == "table" then
            tbl[i].selected = EasyBag.OPTIONS[i].selected
        end 
    end

    return tbl
end

function EasyBag:SearchInventory()
    local items = {}
    for bag = 0, 4 do
        local num_slots =  C_Container.GetContainerNumSlots(bag)
        for slot = 1, num_slots do
            local itemID = C_Container.GetContainerItemID(bag, slot)
            if itemID then
                local itemName, _, _, _, _, itemType, itemSubType, _, equipSlot = GetItemInfo(itemID)
                table.insert(items, {
                    name = itemName, bag = bag, slot = slot, typo = itemType, id = itemID, armorType = equipSlot, subtype = itemSubType
                })
            else
                table.insert(items, {
                    name = "Empty", bag = bag, slot = slot, typo = nil, id = nil, armorType = nil, subtype = nil
                })
            end
        end
    end
    return items
end

function EasyBag:SetDark(frame, alpha)
    if not frame.darkenTexture then
        local darkenTexture = frame:CreateTexture(nil, "OVERLAY")
        darkenTexture:SetAllPoints()
        darkenTexture:SetColorTexture(0, 0, 0, 0.7)
        frame.darkenTexture = darkenTexture
        frame:SetAlpha(alpha or 0.5)

        if frame.IconBorder then
            frame.IconBorder:SetAlpha(alpha or 0.1)
        end
    end
end

function EasyBag:Reveal(frame)
    if frame.darkenTexture then
        frame.darkenTexture:SetColorTexture(0, 0, 0, 0)
        frame.darkenTexture = nil
        frame:SetAlpha(1)

        if frame.IconBorder then
            frame.IconBorder:SetAlpha(1)
        end
    end
end

function EasyBag:GetItemBySlot(bag, slot)
    local items = self:SearchInventory()
    for _, item in ipairs(items) do
        if item.bag == bag and item.slot == slot then
            return item
        end
    end
end

function EasyBag:GetFrameSlot(item_bag, item_slot)
    local frames = ContainerFrameCombinedBags.Items
    for _, frame in pairs(frames) do
        local frame_slot, frame_bag = frame:GetSlotAndBagID()
        if frame_bag == item_bag and frame_slot == item_slot then
            return frame
        end
    end
end

function EasyBag:GetOption(selected)
    local translated_options = EasyBag:Translate()
    for _, option in ipairs(translated_options) do
        if option.selected == selected then
            return option
        end
    end
end

function EasyBag:GetSelectedOption(selected)
    local items = self:SearchInventory()
    local option = self:GetOption(selected)

    for _, item in pairs(items) do
        local frame = self:GetFrameSlot(item.bag, item.slot)
        local reveal = false

        if item.typo == option.typo then
            reveal = true
        end

        if selected == "ARMOR" then
            if item.armorType then
                if item.armorType:match("FINGER") or item.armorType:match("NECK") or item.armorType:match("TRINKET") then
                    reveal = false
                end
            end
        elseif selected == "ACCESORY" then
            reveal = false
            if item.armorType and (item.armorType:match("FINGER") or item.armorType:match("NECK")) then
                reveal = true
            end
        elseif selected == "TRINKET" then
            reveal = false
            if item.armorType and item.armorType:match("TRINKET") then
                reveal = true
            end
        elseif selected == "COLLECTIBLE" then
            if item.name ~= "Empty" then
                local isMount = C_MountJournal.GetMountFromItem(item.id)
                local isPet = C_PetJournal.GetPetInfoByItemID(item.id)
                local isToy = C_ToyBox.GetToyInfo(item.id)

                reveal = false
                if isMount or isPet or isToy then
                    reveal = true
                end
            end
        elseif selected == "QUEST" or selected == "KEY" then
            reveal = false
            if item.subtype == option.subtype then
                reveal = true
            end
        elseif selected == "CHEST" then
            reveal = false
            if item.subtype == option.subtype then
                local containerInfo = C_Container.GetContainerItemInfo(item.bag, item.slot)
                if containerInfo and containerInfo.hasLoot then
                    reveal = true
                end
            end
        elseif selected == "ALL" then
            reveal = true
            EasyBag.selected = nil
        elseif selected == "RECENT" then
            reveal = false
            if EasyBag.recentLoot then
                for _, loot in ipairs(EasyBag.recentLoot) do
                    local lootID, lootName = loot[1], loot[2]
                    if item.id == lootID or item.name == lootName then
                        reveal = true
                    end
                end
            end
        end

        -- if item.name == "Empty" then
        --    reveal = true
        -- end

        if reveal then
            self:Reveal(frame)
        else
            self:SetDark(frame)
        end
    end
end

function EasyBag:CreateDropdownMenu(button)
    local dropdown = CreateFrame("Frame", "EasyBagDropdownMenu", button, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        local translated_options = EasyBag:Translate()
        for _, option in ipairs(translated_options) do
            info.text = option.text
            info.selected = option.selected
            info.func = function()
                EasyBag.selected = option.selected
                EasyBag:GetSelectedOption(option.selected)
            end
            UIDropDownMenu_AddButton(info)
        end
    end, "MENU")

    button:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, dropdown, self, 0, 0) -- Muestra el menú desplegable
    end)

    return dropdown
end

function EasyBag:CreateDropdownButton()
    local button = CreateFrame("Button", "EasyBagFilterButton", ContainerFrameCombinedBags, "CurrencyTransferLogToggleButtonTemplate")
    button:SetSize(22, 22)
    button:SetPoint("TOPLEFT", 32, -35)

    local translated = self:Translate()
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(translated.tooltip, 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    button.dropdown = self:CreateDropdownMenu(button)
    return button
end

function EasyBag:Initialize()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("BAG_UPDATE")
    eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
    eventFrame:RegisterEvent("CHAT_MSG_LOOT")

    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_ENTERING_WORLD" then
            -- Inicialización del addon
            EasyBag:CreateDropdownButton()
            
            -- Detección de ocultación de las bolsas combinadas
            if ContainerFrameCombinedBags then
                ContainerFrameCombinedBags:HookScript("OnHide", function()
                    local frames = ContainerFrameCombinedBags.Items
                    for _, frame in pairs(frames) do
                        EasyBag:Reveal(frame)
                    end
                end)
            end

            if BagItemSearchBox then
                BagItemSearchBox:HookScript("OnTextChanged", function(self)
                    local frames = ContainerFrameCombinedBags.Items
                    for _, frame in pairs(frames) do
                        EasyBag:Reveal(frame)
                    end
                end)
            end
        elseif  event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
            if EasyBag.selected then
                EasyBag:GetSelectedOption(EasyBag.selected)
            end
        elseif event == "CHAT_MSG_LOOT" then
            local text = ...
            local itemLink = string.match(text, "|c%x+|Hitem:.-|h.-|h|r")
            if itemLink then
                local itemID = string.match(itemLink, "Hitem:(%d+)")

                if not EasyBag.countdownActive then
                    EasyBag.recentLoot = {}
                    EasyBag.countdownActive = true
                    EasyBag.countdown = C_Timer.After(1.2, function()
                        EasyBag.countdownActive = false
                    end)
                end

                if EasyBag.countdownActive then
                    EasyBag.recentLoot = EasyBag.recentLoot or {}
                    table.insert(EasyBag.recentLoot, {itemID, GetItemInfo(itemLink)})
                end
            end
        end
    end)
end

EasyBag:Initialize()