local Query = EasyBag:NewModule("Query")

function Query:IsArmor(item)
	if item.armorType then
		local armors = {"HEAD", "SHOULDER", "CHEST", "WAIST", "LEGS", "FEET", "WRIST", "HANDS", "BACK", "SHIRT", "TABARD"}
		for _, armor in ipairs(armors) do
			if item.armorType:match(armor) then
				return true
			end
		end
	end
	return false
end

function Query:IsWeapon(item, option)
	if item.typo then
		if item.typo == option.typo then
			return true
		end
	end
	return false
end

function Query:IsRecipe(item, option)
	if item.typo then
		if item.typo == option.typo then
			return true
		end
	end
	return false
end

function Query:IsConsumable(item, option)
	if item.typo then
		if item.typo == option.typo then
			return true
		end
	end
	return false
end

function Query:IsMaterial(item, option)
	print(item.typo)
	if item.typo then
		if item.typo == option.typo then
			return true
		end
	end
	return false
end

function Query:IsRecentLoot(item)
	if EasyBag.recentLoot then
		for _, loot in ipairs(EasyBag.recentLoot) do
			local lootID, lootName = loot[1], loot[2]
			if item.id == lootID or item.name == lootName then
				return true
			end
		end
	end
	return false
end

function Query:IsAccesory(item)
	if item.armorType then
		if item.armorType:match("FINGER") or item.armorType:match("NECK") then
			return true
		end
	end
	return false
end

function Query:IsTrincket(item)
	if item.armorType and item.armorType:match("TRINKET") then
		return true
	end
	return false
end

function Query:IsQuest(item, option)
	if item.subtype == option.subtype then
		return true
	end
	return false
end

function Query:IsChest(item, option)
	if item.subtype == option.subtype then
		local containerInfo = C_Container.GetContainerItemInfo(item.bag, item.slot)
		if containerInfo and containerInfo.hasLoot then
			return true
		end
	end
	return false
end

function Query:IsCollectible(item)
	if item.name ~= "Empty" then
		local isMount = C_MountJournal.GetMountFromItem(item.id)
		local isPet = C_PetJournal.GetPetInfoByItemID(item.id)
		local isToy = C_ToyBox.GetToyInfo(item.id)

		if isMount or isPet or isToy then
			return true
		end
	end
	return false
end