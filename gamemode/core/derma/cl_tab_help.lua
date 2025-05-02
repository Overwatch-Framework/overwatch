local padding = ScreenScale(32)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    local title = self:Add("ow.text")
    title:Dock(TOP)
    title:SetFont("ow.fonts.title")
    title:SetText("HELP")

    self.buttons = self:Add("DHorizontalScroller")
    self.buttons:Dock(TOP)
    self.buttons:DockMargin(0, padding / 8, 0, 0)
    self.buttons:SetTall(ScreenScale(24))
    self.buttons.Paint = nil

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container:GetVBar():SetWide(0)
    self.container.Paint = nil

    local categories = {}
    hook.Run("PopulateHelpCategories", categories)
    for k, v in SortedPairs(categories) do
        local button = self.buttons:Add("ow.mainmenu.button.small")
        button:Dock(LEFT)
        button:SetText(k)
        button:SizeToContents()

        button.DoClick = function()
            ow.gui.helpLast = k

            self:Populate(v)
        end
    end

    for k, v in SortedPairs(categories) do
        if ( ow.gui.helpLast ) then 
            if ( ow.gui.helpLast == k ) then
                self:Populate(v)
                break
            end
        else
            self:Populate(v)
            break
        end
    end
end

function PANEL:Populate(data)
    if ( !data ) then return end

    self.container:Clear()

    if ( istable(data) ) then
        if ( isfunction(data.Populate) ) then
            data:Populate(self.container)
        end

        if ( data.OnClose ) then
            self:CallOnRemove("ow.tab.help." .. data.name, function()
                data.OnClose()
            end)
        end
    elseif ( isfunction(data) ) then
        data(self.container)
    end
end

vgui.Register("ow.tab.help", PANEL, "EditablePanel")

ow.gui.helpLast = nil