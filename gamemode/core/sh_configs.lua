ow.config:Register("color.framework", {
    Name = "config.color.framework",
    Description = "config.color.framework.help",
    Type = ow.types.color,
    Default = Color(105, 255, 200)
})

ow.config:Register("color.schema", {
    Name = "config.color.schema",
    Description = "config.color.schema.help",
    Type = ow.types.color,
    Default = Color(0, 150, 100)
})

ow.config:Register("voice", {
    Name = "config.voice",
    Description = "config.voice.help",
    Type = ow.types.bool,
    Default = true
})

ow.config:Register("voice.distance", {
    Name = "config.voice.distance",
    Description = "config.voice.distance.help",
    Type = ow.types.number,
    Default = 384,
    Min = 0,
    Max = 1024,
    Decimals = 0
})

ow.config:Register("mainmenu.music", {
    Name = "config.mainmenu.music",
    Description = "config.mainmenu.music.help",
    SubCategory = "config.mainmenu",
    Type = ow.types.string,
    Default = "music/hl2_song20_submix0.mp3"
})

ow.config:Register("mainmenu.pos", {
    Name = "config.mainmenu.pos",
    Description = "config.mainmenu.pos.help",
    SubCategory = "config.mainmenu",
    Type = ow.types.vector,
    Default = vector_origin
})

ow.config:Register("mainmenu.ang", {
    Name = "config.mainmenu.ang",
    Description = "config.mainmenu.ang.help",
    SubCategory = "config.mainmenu",
    Type = ow.types.angle,
    Default = angle_zero
})

ow.config:Register("mainmenu.fov", {
    Name = "config.mainmenu.fov",
    Description = "config.mainmenu.fov.help",
    SubCategory = "config.mainmenu",
    Type = ow.types.number,
    Default = 90,
    Min = 0,
    Max = 120,
    Decimals = 0
})

ow.config:Register("save.interval", {
    Name = "config.save.interval",
    Description = "config.save.interval.help",
    Type = ow.types.number,
    Default = 300,
    Min = 0,
    Max = 3600,
    Decimals = 0
})

ow.config:Register("speed.walk", {
    Name = "config.speed.walk",
    Description = "config.speed.walk.help",
    SubCategory = "config.player",
    Type = ow.types.number,
    Default = 80,
    Min = 0,
    Max = 1000,
    Decimals = 0,
    OnChange = function(_, value)
        if ( CLIENT ) then return end

        for _, client in player.Iterator() do
            client:SetWalkSpeed(value)
        end
    end
})

ow.config:Register("speed.run", {
    Name = "config.speed.run",
    Description = "config.speed.run.help",
    SubCategory = "config.player",
    Type = ow.types.number,
    Default = 180,
    Min = 0,
    Max = 1000,
    Decimals = 0,
    OnChange = function(_, value)
        if ( CLIENT ) then return end

        for _, client in player.Iterator() do
            client:SetRunSpeed(value)
        end
    end
})

ow.config:Register("jump.power", {
    Name = "config.jump.power",
    Description = "config.jump.power.help",
    SubCategory = "config.player",
    Type = ow.types.number,
    Default = 160,
    Min = 0,
    Max = 1000,
    Decimals = 0,
    OnChange = function(_, value)
        if ( CLIENT ) then return end

        for _, client in player.Iterator() do
            client:SetJumpPower(value)
        end
    end
})

ow.config:Register("inventory.maxweight", {
    Name = "config.inventory.maxweight",
    Description = "config.inventory.maxweight.help",
    SubCategory = "config.inventory",
    Type = ow.types.number,
    Default = 20,
    Min = 0,
    Max = 100,
    Decimals = 2,
    OnChange = function(_, value)
        for _, client in player.Iterator() do
            local character = client:GetCharacter()
            if ( character ) then
                local inventories = ow.inventory:GetByCharacterID(character:GetID())
                for _, inventory in ipairs(inventories) do
                    inventory.maxWeight = value
                end
            end
        end
    end
})

ow.config:Register("chat.radius.ic", {
    Name = "config.chat.radius.ic",
    Description = "config.chat.radius.ic.help",
    Category = "config.chat",
    Type = ow.types.number,
    Default = 384,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("chat.radius.whisper", {
    Name = "config.chat.radius.whisper",
    Description = "config.chat.radius.whisper.help",
    Category = "config.chat",
    Type = ow.types.number,
    Default = 96,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("chat.radius.yell", {
    Name = "config.chat.radius.yell",
    Description = "config.chat.radius.yell.help",
    Category = "config.chat",
    Type = ow.types.number,
    Default = 1024,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("chat.radius.me", {
    Name = "config.chat.radius.me",
    Description = "config.chat.radius.me.help",
    Category = "config.chat",
    Type = ow.types.number,
    Default = 512,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("chat.radius.it", {
    Name = "config.chat.radius.it",
    Description = "config.chat.radius.it.help",
    Category = "config.chat",
    Type = ow.types.number,
    Default = 512,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("chat.radius.looc", {
    Name = "config.chat.radius.looc",
    Description = "config.chat.radius.looc.help",
    Category = "config.chat",
    Type = ow.types.number,
    Default = 512,
    Min = 0,
    Max = 1000,
    Decimals = 0
})

ow.config:Register("chat.ooc", {
    Name = "config.chat.ooc",
    Description = "config.chat.ooc.help",
    Category = "config.chat",
    Type = ow.types.bool,
    Default = true,
})

ow.config:Register("currency.singular", {
    Name = "config.currency.singular",
    Description = "config.currency.singular.help",
    Category = "config.currency",
    Type = ow.types.string,
    Default = "Dollar"
})

ow.config:Register("currency.plural", {
    Name = "config.currency.plural",
    Description = "config.currency.plural.help",
    Category = "config.currency",
    Type = ow.types.string,
    Default = "Dollars"
})
ow.config:Register("currency.symbol", {
    Name = "config.currency.symbol",
    Description = "config.currency.symbol.help",
    Category = "config.currency",
    Type = ow.types.string,
    Default = "$"
})

ow.config:Register("currency.model", {
    Name = "config.currency.model",
    Description = "config.currency.model.help",
    Category = "config.currency",
    Type = ow.types.string,
    Default = "models/props_junk/cardboard_box004a.mdl"
})

ow.config:Register("mainmenu.branchwarning", {
    Name = "config.mainmenu.branchwarning",
    Description = "config.mainmenu.branchwarning.help",
    Category = "config.mainmenu",
    Type = ow.types.bool,
    Default = true
})

ow.config:Register("hands.max.carry", {
    Name = "config.hands.max.carry",
    Description = "config.hands.max.carry.help",
    Category = "config.hands",
    Type = ow.types.number,
    Default = 160,
    Min = 0,
    Max = 500,
    Decimals = 0
})

ow.config:Register("hands.max.force", {
    Name = "config.hands.max.force",
    Description = "config.hands.max.force.help",
    Category = "config.hands",
    Type = ow.types.number,
    Default = 16500,
    Min = 0,
    Max = 50000,
    Decimals = 0
})

ow.config:Register("hands.max.throw", {
    Name = "config.hands.max.throw",
    Description = "config.hands.max.throw.help",
    Category = "config.hands",
    Type = ow.types.number,
    Default = 150,
    Min = 0,
    Max = 256,
    Decimals = 0
})

ow.config:Register("hands.range", {
    Name = "config.hands.range",
    Description = "config.hands.range.help",
    Category = "config.hands",
    Type = ow.types.number,
    Default = 96,
    Min = 0,
    Max = 256,
    Decimals = 0
})

ow.config:Register("wepraise.time", {
    Name = "config.wepraise.time",
    Description = "config.wepraise.time.help",
    Type = ow.types.number,
    SubCategory = "config.wepraise",
    Default = 1,
    Min = 0,
    Max = 5,
    Decimals = 1
})

ow.config:Register("wepraise.alwaysraised", {
    Name = "config.wepraise.alwaysraised",
    Description = "config.wepraise.alwaysraised.help",
    SubCategory = "config.wepraise",
    Type = ow.types.bool,
    Default = false
})