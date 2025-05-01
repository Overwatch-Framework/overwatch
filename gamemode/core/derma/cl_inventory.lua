local padding = ScreenScale(32)
local smallPadding = padding / 2
local tinyPadding = smallPadding / 2

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    ow.gui.inventory = self

    self:Dock(FILL)

    self.buttons = self:Add("DHorizontalScroller")
    self.buttons:Dock(TOP)
    self.buttons:DockMargin(0, padding / 8, 0, 0)
    self.buttons:SetTall(ScreenScale(24))
    self.buttons.Paint = nil

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container.Paint = nil

    self.info = self:Add("DPanel")
    self.info:Dock(RIGHT)
    self.info:DockPadding(16, 16, 16, 16)
    self.info:SetWide(ScreenScale(128))
    self.info.Paint = function(this, width, height)
        draw.RoundedBox(0, 0, 0, width, height, Color(0, 0, 0, 150))
    end

    local inventories = ow.inventory:GetByCharacterID(ow.localClient:GetCharacter():GetID())
    if ( #inventories == 0 ) then
        local label = self.buttons:Add("ow.text")
        label:Dock(FILL)
        label:SetFont("ow.fonts.large")
        label:SetText("inventory.empty")
        label:SetContentAlignment(5)

        return
    end

    for _, inventory in pairs(inventories) do
        local button = self.buttons:Add("ow.mainmenu.button.small")
        button:Dock(LEFT)
        button:SetText(inventory:GetName())
        button:SizeToContents()

        button.DoClick = function()
            self:SetInventory(inventory:GetID())
        end
    end

    -- Pick the first inventory by default
    local firstInventory = inventories[1]
    if ( firstInventory ) then
        self:SetInventory(firstInventory:GetID())
    end
end

function PANEL:SetInventory(id)
    if ( !id ) then return end

    local inventory = ow.inventory:Get(id)
    if ( !inventory ) then return end

    self.container:Clear()

    local total = inventory:GetWeight() / ow.config:Get("inventory.maxweight", 20)

    local progress = self.container:Add("DProgress")
    progress:Dock(TOP)
    progress:SetFraction(total)
    progress:SetTall(ScreenScale(12))
    progress.Paint = function(this, width, height)
        draw.RoundedBox(0, 0, 0, width, height, Color(0, 0, 0, 150))

        local fraction = this:GetFraction()
        draw.RoundedBox(0, 0, 0, width * fraction, height, Color(100, 200, 175, 200))
    end

    local maxWeight = ow.config:Get("inventory.maxweight", 20)
    local weight = math.Round(maxWeight * progress:GetFraction(), 2)

    local label = progress:Add("ow.text")
    label:Dock(FILL)
    label:SetFont("ow.fonts.large")
    label:SetText(weight .. "kg / " .. maxWeight .. "kg")
    label:SetTextColor(color_white)

    local items = inventory:GetItems()
    if ( #items == 0 ) then return end

    for k, v in pairs(items) do
        local itemPanel = self.container:Add("ow.item")
        itemPanel:SetItem(v)
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(0, 0, 0, padding / 8)
    end
end

function PANEL:SetInfo(id)
    if ( !id ) then return end

    local item = ow.item:Get(id)
    if ( !item ) then return end

    self.info:Clear()

    local icon = self.info:Add("DAdjustableModelPanel")
    icon:Dock(TOP)
    icon:SetSize(self.info:GetWide() - 32, self.info:GetWide() - 32)
    icon:SetModel(item:GetModel())
    icon:SetSkin(item:GetSkin())

    local entity = icon:GetEntity()
    local pos = entity:GetPos()
    local camData = PositionSpawnIcon(entity, pos)
    if ( camData ) then
        icon:SetCamPos(camData.origin)
        icon:SetFOV(camData.fov)
        icon:SetLookAng(camData.angles)
    end

    local name = self.info:Add("ow.text")
    name:Dock(TOP)
    name:DockMargin(0, 0, 0, -padding / 8)
    name:SetFont("ow.fonts.extralarge.bold")
    name:SetText(item:GetName(), true)

    local description = item:GetDescription()
    local descriptionWrapped = ow.util:WrapText(description, "ow.fonts.default", self.info:GetWide() - 32)
    for k, v in pairs(descriptionWrapped) do
        local text = self.info:Add("ow.text")
        text:Dock(TOP)
        text:SetFont("ow.fonts.default")
        text:SetText(v, true)
    end
end

vgui.Register("ow.inventory", PANEL, "EditablePanel")

DEFINE_BASECLASS("ow.mainmenu.button.small")

PANEL = {}

AccessorFunc(PANEL, "id", "ID", FORCE_NUMBER)

function PANEL:Init()
    self:SetText("")
    self:SetTall(ScreenScale(16))

    self.id = 0

    self.icon = self:Add("SpawnIcon")
    self.icon:Dock(LEFT)
    self.icon:DockMargin(0, 0, padding / 8, 0)
    self.icon:SetSize(self:GetTall(), self:GetTall())
    self.icon:SetMouseInputEnabled(false)

    self.name = self:Add("ow.text")
    self.name:Dock(FILL)
    self.name:SetFont("ow.fonts.large")
    self.name:SetContentAlignment(4)
    self.name:SetMouseInputEnabled(false)

    self.weight = self:Add("ow.text")
    self.weight:Dock(RIGHT)
    self.weight:DockMargin(0, 0, padding / 8, 0)
    self.weight:SetFont("ow.fonts.default")
    self.weight:SetContentAlignment(6)
    self.weight:SetWide(ScreenScale(64))
    self.weight:SetMouseInputEnabled(false)
end

function PANEL:SetItem(id)
    if ( !id ) then return end
    self:SetID(id)

    local item = ow.item:Get(id)
    if ( !item ) then return end

    self.icon:SetModel(item:GetModel())
    self.name:SetText(item:GetName(), true)
    self.weight:SetText(item:GetWeight() .. "kg", true, true)
end

function PANEL:DoClick()
    local inventoryPanel = ow.gui.inventory
    if ( !IsValid(inventoryPanel) ) then return end

    inventoryPanel:SetInfo(self:GetID())
end

-- Boss didnt want tooltips :(
/*
function PANEL:OnHovered()
    local item = ow.item:Get(self:GetID())
    if ( !item ) then return end

    local name = item:GetName()
    local description = item:GetDescription()

    if ( !IsValid(ow.gui.tooltip) ) then
        ow.gui.tooltip = vgui.Create("ow.tooltip")
        ow.gui.tooltip:SetText(name, description)
        ow.gui.tooltip:SizeToContents()
        ow.gui.tooltip:SetPanel(self)
    else
        ow.gui.tooltip:SetText(name, description)
        ow.gui.tooltip:SizeToContents()

        timer.Simple(0, function()
            if ( IsValid(ow.gui.tooltip) ) then
                ow.gui.tooltip:SetPanel(self)
            end
        end)
    end
end

function PANEL:OnUnHovered()
    if ( IsValid(ow.gui.tooltip) ) then
        ow.gui.tooltip:SetPanel(nil)
    end
end
*/

function PANEL:Think()
    BaseClass.Think(self)

    self.name:SetTextColor(self:GetTextColor())
    self.weight:SetTextColor(self:GetTextColor())
end

vgui.Register("ow.item", PANEL, "ow.mainmenu.button.small")