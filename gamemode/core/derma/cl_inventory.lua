local padding = ScreenScale(32)

DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
    self:Dock(FILL)

    self.buttons = self:Add("DHorizontalScroller")
    self.buttons:Dock(TOP)
    self.buttons:DockMargin(0, padding / 8, 0, 0)
    self.buttons:SetTall(ScreenScale(24))
    self.buttons.Paint = nil

    self.container = self:Add("DScrollPanel")
    self.container:Dock(FILL)
    self.container.Paint = nil

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
        button:SetText(inventory:GetName() .. " (" .. inventory:GetID() .. ")")
        button:SizeToContents()

        button.DoClick = function()
            self:SetInventory(inventory:GetID())
        end
    end
end

function PANEL:SetInventory(id)
    if ( !id ) then return end

    local inventory = ow.inventory:Get(id)
    if ( !inventory ) then return end

    self.container:Clear()

    local progress = self.container:Add("DProgress")
    progress:Dock(TOP)
    progress:SetFraction(math.Rand(0, 1))
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
    label:SetTextColor(Color(255, 255, 255, 255))
    label:SetContentAlignment(5)
    label:SetExpensiveShadow(0, Color(0, 0, 0, 0))

    local items = inventory:GetItems()
    PrintTable(items)
    if ( #items == 0 ) then return end

    for k, v in pairs(items) do
        local itemPanel = self.container:Add("ow.item")
        itemPanel:SetItem(v)
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(0, 0, 0, padding / 8)
    end
end

vgui.Register("ow.inventory", PANEL, "EditablePanel")

PANEL = {}

function PANEL:Init()
    self:SetTall(ScreenScale(32))

    self.icon = self:Add("SpawnIcon")
    self.icon:Dock(LEFT)
    self.icon:DockMargin(0, 0, padding / 8, 0)
    self.icon:SetSize(self:GetTall(), self:GetTall())

    self.name = self:Add("ow.text")
    self.name:Dock(TOP)
    self.name:SetFont("ow.fonts.large")

    self.description = self:Add("ow.text")
    self.description:Dock(FILL)
    self.description:SetFont("ow.fonts.default")

    self.weight = self:Add("ow.text")
    self.weight:Dock(RIGHT)
    self.weight:SetFont("ow.fonts.default")
    self.weight:SetWide(ScreenScale(64))
end

function PANEL:SetItem(id)
    if ( !id ) then return end

    local item = ow.item:Get(id)
    if ( !item ) then return end

    PrintTable(item)

    self.icon:SetModel(item:GetModel())
    self.name:SetText(item:GetName())
    self.description:SetText(item:GetDescription())
    self.weight:SetText(item:GetWeight() .. "kg", true, true)
end

function PANEL:Paint(width, height)
    draw.RoundedBox(0, 0, 0, width, height, Color(0, 0, 0, 150))
end

vgui.Register("ow.item", PANEL, "EditablePanel")