local padding = ScreenScale(32)
local gradientLeft = Material("vgui/gradient-l")

local PANEL = {}

function PANEL:Init()
    if ( IsValid(ow.gui.mainmenu) ) then
        ow.gui.mainmenu:Remove()
    end

    ow.gui.mainmenu = self

    self:SetSize(ScrW(), ScrH())
    self:MakePopup()

    local sideButtons = self:Add("EditablePanel")
    sideButtons:Dock(LEFT)
    sideButtons:SetSize(self:GetWide() / 2, self:GetTall())
    sideButtons.Paint = function(this, width, height)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.SetMaterial(gradientLeft)
        surface.DrawTexturedRect(0, 0, width, height)
    end

    local title = sideButtons:Add("DLabel")
    title:Dock(TOP)
    title:DockMargin(padding, padding, padding, 0)
    title:SetFont("ow.fonts.title")
    title:SetText("OVERWATCH")
    title:SetTextColor(Color(0, 100, 150))
    title:SetExpensiveShadow(4, Color(0, 0, 0, 200))
    title:SizeToContents()

    local subtitle = sideButtons:Add("DLabel")
    subtitle:Dock(TOP)
    subtitle:DockMargin(padding * 1.5, 0, padding, 0)
    subtitle:SetFont("ow.fonts.subtitle")
    subtitle:SetText(string.upper(SCHEMA.Name))
    subtitle:SetTextColor(color_white)
    subtitle:SetExpensiveShadow(4, Color(0, 0, 0, 200))
    subtitle:SizeToContents()

    local buttons = sideButtons:Add("EditablePanel")
    buttons:Dock(FILL)
    buttons:DockMargin(padding * 2, padding, padding * 4, padding)

    -- TODO: add real buttons like "Create Character", "Select Character", "Settings", "Credits", etc.
    for i = 1, 5 do
        local button = buttons:Add("DButton")
        button:Dock(TOP)
        button:SetTall(ScreenScale(14))
        button:SetText("Button " .. i)
        button:SetFont("ow.fonts.default")
        button:SetTextColor(color_white)
        button.Paint = function(this, width, height)
            local color = Color(0, 0, 0, 150)
            if ( this.Depressed or this:IsSelected() ) then
                color = Color(0, 0, 0, 200)
            elseif ( this.Hovered ) then
                color = Color(0, 0, 0, 200)
            end

            draw.RoundedBox(0, 0, 0, width, height, color)
        end
        button.DoClick = function()
            LocalPlayer():EmitSound("ow.button.click")

            if ( i == 1 ) then
                print("Button 1 clicked!")

                self:Remove()
            elseif ( i == 2 ) then
                print("Button 2 clicked!")
            elseif ( i == 3 ) then
                print("Button 3 clicked!")
            elseif ( i == 4 ) then
                print("Button 4 clicked!")
            elseif ( i == 5 ) then
                print("Button 5 clicked!")

                Derma_Query("Are you sure you want to quit?", "Quit Overwatch", "Yes", function()
                    RunConsoleCommand("disconnect")
                end, "No", function() end)
            end
        end
        button.OnCursorEntered = function()
            LocalPlayer():EmitSound("ow.button.enter")
        end
    end
end

vgui.Register("ow.mainmenu", PANEL, "EditablePanel")

if ( IsValid(ow.gui.mainmenu) ) then
    ow.gui.mainmenu:Remove()
end

-- TODO: add an actual button panel
sound.Add({
    name = "ow.button.click",
    channel = CHAN_STATIC,
    volume = 0.2,
    level = 80,
    pitch = 120,
    sound = "buttons/button9.wav"
})

sound.Add({
    name = "ow.button.enter",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 80,
    pitch = 120,
    sound = "buttons/lightswitch2.wav"
})