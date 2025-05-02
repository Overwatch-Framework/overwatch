ow.currency = ow.currency or {}

do
    ow.config:Register("currency.singular", {
        Name = "config.currency.singular",
        Description = "config.currency.singular.help",
        Category = "config.currency",
        Type = ow.type.string,
        Default = "Dollar"
    })

    ow.config:Register("currency.plural", {
        Name = "config.currency.plural",
        Description = "config.currency.plural.help",
        Category = "config.currency",
        Type = ow.type.string,
        Default = "Dollars"
    })
    ow.config:Register("currency.symbol", {
        Name = "config.currency.symbol",
        Description = "config.currency.symbol.help",
        Category = "config.currency",
        Type = ow.type.string,
        Default = "$"
    })

    ow.config:Register("currency.model", {
        Name = "config.currency.model",
        Description = "config.currency.model.help",
        Category = "config.currency",
        Type = ow.type.string,
        Default = "models/props_junk/cardboard_box004a.mdl"
    })
end

function ow.currency:GetSingular()
    return ow.config:Get("currency.singular")
end

function ow.currency:GetPlural()
    return ow.config:Get("currency.plural")
end

function ow.currency:GetSymbol()
    return ow.config:Get("currency.symbol")
end

function ow.currency:Format(amount, bNoSymbol, bComma)
    if ( !isnumber(amount) ) then return amount end

    local symbol = bNoSymbol and "" or self:GetSymbol()
    local formatted = !bComma and amount or string.Comma(amount)

    return symbol .. formatted
end

if ( SERVER ) then
    function ow.currency:Spawn(amount, pos, ang)
        local ent = ents.Create("ow_currency")
        if ( !IsValid(ent) ) then return end

        ent:SetPos(pos or vector_origin)
        ent:SetAngles(ang or angle_zero)
        ent:SetAmount(amount or 1)
        ent:Spawn()
        ent:Activate()

        return ent
    end
end