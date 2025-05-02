DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:SetFont("ow.fonts.title")
    title:SetText("SETTINGS")

    local settings = self:Add("ow.settings")
    settings:Dock(FILL)
end

vgui.Register("ow.tab.settings", PANEL, "EditablePanel")