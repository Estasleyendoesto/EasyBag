local Filter = EasyBag:NewModule("Filter", "AceEvent-3.0")
local Locale
local Slot
local Query

function Filter:OnInitialize()
    Locale = EasyBag:GetModule("Locale")
    Query = EasyBag:GetModule("Query")
    Slot = EasyBag:GetModule("Slot")
end

function Filter:OnEnable()
    self:RegisterMessage("REFRESH_FILTER", "RefreshFilter")
end

function Filter:SearchInventory()
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

function Filter:GetFrameSlot(item_bag, item_slot)
    local frames = ContainerFrameCombinedBags.Items
    for _, frame in pairs(frames) do
        local frame_slot, frame_bag = frame:GetSlotAndBagID()
        if frame_bag == item_bag and frame_slot == item_slot then
            return frame
        end
    end
end

function Filter:GetSelectedOption(selected)
	local items = self:SearchInventory()
    local option = Locale:GetOption(selected)

	for _, item in pairs(items) do
		local frame = self:GetFrameSlot(item.bag, item.slot)

		local reveal = false

		if selected == "ARMOR" then
            reveal = Query:IsArmor(item)
        elseif selected == "WEAPON" then
            reveal = Query:IsWeapon(item, option)
		elseif selected == "ACCESORY" then
            reveal = Query:IsAccesory(item)
		elseif selected == "TRINKET" then
            reveal = Query:IsTrincket(item)
		elseif selected == "COLLECTIBLE" then
            reveal = Query:IsCollectible(item)
		elseif selected == "QUEST" or selected == "KEY" then
            reveal = Query:IsQuest(item, option)
		elseif selected == "CHEST" then
            reveal = Query:IsChest(item, option)
        elseif selected == "RECIPE" then
            reveal = Query:IsRecipe(item, option)
        elseif selected == "CONSUMABLE" then
            reveal = Query:IsConsumable(item, option)
        elseif selected == "MATERIAL" then
            reveal = Query:IsMaterial(item, option)
		elseif selected == "RECENT" then
            reveal = Query:IsRecentLoot(item)
        elseif selected == "ALL" then
			reveal = true
		end

		if reveal then
            Slot:Reveal(frame)
        else
            Slot:SetDark(frame)
        end
	end

	-- Redundante, sí, pero es más preciso
	if selected == "ALL" then
        EasyBag.selectedOption = nil
		self:SendMessage("HIDE_RESET_BUTTON")
	else
        EasyBag.selectedOption = option.selected
		self:SendMessage("SHOW_RESET_BUTTON")
	end
end

function Filter:ResetFilter()
	self:GetSelectedOption("ALL")
end

function Filter:RefreshFilter()
    if EasyBag.selectedOption then
        self:GetSelectedOption(EasyBag.selectedOption)
    end
end