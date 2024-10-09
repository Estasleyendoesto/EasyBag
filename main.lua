EasyBag = LibStub("AceAddon-3.0"):NewAddon("EasyBag")
EasyBag:SetDefaultModuleState(false)

LOCALIZATION = {}

function EasyBag:OnInitialize()
	self.recentLoot = {}
	self.selectedOption = nil
end

function EasyBag:OnEnable()
	self:EnableModule("Menu")
	self:EnableModule("Events")
	self:EnableModule("Slot")
	self:EnableModule("Filter")
end