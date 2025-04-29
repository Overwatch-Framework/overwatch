DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:SetFont("ow.fonts.title")
    title:SetText("INVENTORY")

    local inventory = self:Add("ow.inventory")
    inventory:Dock(FILL)
    inventory:SetInventory()
end

vgui.Register("ow.tab.inventory", PANEL, "EditablePanel")