DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:SetFont("ow.fonts.title")
    title:SetText("INVENTORY")

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
end

vgui.Register("ow.tab.inventory", PANEL, "EditablePanel")