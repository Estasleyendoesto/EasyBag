local Menu = EasyBag:NewModule("Menu", "AceEvent-3.0")
local Locale
local Filter

function Menu:OnInitialize()
    Locale = EasyBag:GetModule("Locale")
    Filter = EasyBag:GetModule("Filter")
end

function Menu:OnEnable()
    self.reset_button = nil
	self:CreateDropdownButton()
    self:RegisterMessage("HIDE_RESET_BUTTON", "ToggleResetButton", false)
    self:RegisterMessage("SHOW_RESET_BUTTON", "ToggleResetButton", true)
end

function Menu:CreateDropdownMenu(button)
    local dropdown = CreateFrame("Frame", "EasyBagDropdownMenu", button, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        local translated_options = Locale:Translate()
        for _, option in ipairs(translated_options) do
            info.text = option.text
            info.selected = option.selected
            info.func = function()
                Filter:GetSelectedOption(option.selected)
            end
            UIDropDownMenu_AddButton(info)
        end
    end, "MENU")

    button:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, dropdown, self, 0, 0) -- Muestra el menú desplegable
    end)

    return dropdown
end

function Menu:ResetFilterButton()
    Filter:ResetFilter()
end

function Menu:CreateDropdownButton()
	local button = CreateFrame("Button", "EasyBagFilterButton", ContainerFrameCombinedBags, "CurrencyTransferLogToggleButtonTemplate")
    button:SetSize(22, 22)
    button:SetPoint("TOPLEFT", 32, -35)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(Locale:Translate().filter, 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button.dropdown = self:CreateDropdownMenu(button)
    return button
end

function Menu:CreateResetButton()
    local button = CreateFrame("Button", "EasyBagResetButton", ContainerFrameCombinedBags, "UIPanelCloseButton")
    button:SetSize(22, 22)
    button:SetPoint("TOPLEFT", 10, -36)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(Locale:Translate().reset, 1, 1, 1)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    button:SetScript("OnClick", function()
        Menu:ResetFilterButton()
    end)

    return button
end

function Menu:ToggleResetButton(toggle)
    if toggle then
        if not self.reset_button then
            self.reset_button = self:CreateResetButton()
        end
    else
        if self.reset_button then
            self.reset_button:SetParent(nil)
            self.reset_button:Hide()
            self.reset_button = nil
        end
    end
end