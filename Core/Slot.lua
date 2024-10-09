local Slot = EasyBag:NewModule("Slot", "AceEvent-3.0")

function Slot:OnEnable()
	self:RegisterMessage("SET_DARK_ALL", "ToggleSlots", false)
	self:RegisterMessage("SET_REVEAL_ALL", "ToggleSlots", true)
end

function Slot:SetDark(frame, alpha)
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

function Slot:Reveal(frame)
    if frame.darkenTexture then
        frame.darkenTexture:SetColorTexture(0, 0, 0, 0)
        frame.darkenTexture = nil
        frame:SetAlpha(1)

        if frame.IconBorder then
            frame.IconBorder:SetAlpha(1)
        end
    end
end

function Slot:ToggleSlots(reveal)
	local frames = ContainerFrameCombinedBags.Items
	for _, frame in pairs(frames) do
		if frame then
			if reveal then
				self:Reveal(frame)
			else
				self:SetDark(frame)
			end
		end
	end
end