DEFINE_BASECLASS("DLabel")

local PANEL = {}

function PANEL:Init()
    self:SetFont("ow.fonts")
    self:SetTextColor(color_white)
end

function PANEL:SetText(text, bNoTranslate, bNoSizeToContents)
    if ( !bNoTranslate ) then
        -- we need to check if the text is upper case, because the localization function will convert it to lower case
        -- after that we can convert it back to upper case if needed
        local isUpper = false
        if ( string.upper(text) == text ) then
            isUpper = true
        end

        text = ow.localization:GetPhrase(string.lower(text))

        if ( isUpper ) then
            text = string.upper(text)
        end
    end

    BaseClass.SetText(self, text)

    if ( !bNoSizeToContents ) then
        self:SizeToContents()
    end
end

function PANEL:SizeToContents()
    BaseClass.SizeToContents(self)

    local width, height = self:GetSize()
    self:SetSize(width + 8, height + 4)
end

vgui.Register("ow.text", PANEL, "DLabel")