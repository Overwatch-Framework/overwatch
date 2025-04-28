ow.config:Register("color.framework", {
    Name = "config.color.framework.name",
    Description = "config.color.framework.help",
    Type = ow.type.color,
    Default = Color(0, 100, 150)
})

ow.config:Register("color.schema", {
    Name = "config.color.schema.name",
    Description = "config.color.schema.help",
    Type = ow.type.color,
    Default = Color(0, 150, 100)
})

ow.config:Register("voice.distance", {
    Name = "config.voice.distance.name",
    Description = "config.voice.distance.help",
    Type = ow.type.number,
    Default = 384
})

ow.config:Register("mainmenu.music", {
    Name = "config.mainmenu.music.name",
    Description = "config.mainmenu.music.help",
    Type = ow.type.string,
    Default = "music/hl2_song20_submix0.mp3"
})

ow.config:Register("mainmenu.pos", {
    Name = "config.mainmenu.pos.name",
    Description = "config.mainmenu.pos.help",
    Type = ow.type.vector,
    Default = vector_origin
})

ow.config:Register("mainmenu.ang", {
    Name = "config.mainmenu.ang.name",
    Description = "config.mainmenu.ang.help",
    Type = ow.type.angle,
    Default = angle_zero
})

ow.config:Register("mainmenu.fov", {
    Name = "config.mainmenu.fov.name",
    Description = "config.mainmenu.fov.help",
    Type = ow.type.number,
    Default = 90
})

ow.config:Register("save.interval", {
    Name = "config.save.interval.name",
    Description = "config.save.interval.help",
    Type = ow.type.number,
    Default = 300
})

ow.config:Register("speed.walk", {
    Name = "config.speed.walk.name",
    Description = "config.speed.walk.help",
    Type = ow.type.number,
    Default = 80,
    OnChange = function(value)
        for _, ply in player.Iterator() do
            ply:SetWalkSpeed(value)
        end
    end
})

ow.config:Register("speed.run", {
    Name = "config.speed.run.name",
    Description = "config.speed.run.help",
    Type = ow.type.number,
    Default = 180,
    OnChange = function(value)
        for _, ply in player.Iterator() do
            ply:SetRunSpeed(value)
        end
    end
})

ow.config:Register("jump.power", {
    Name = "config.jump.power.name",
    Description = "config.jump.power.help",
    Type = ow.type.number,
    Default = 160,
    OnChange = function(value)
        for _, ply in player.Iterator() do
            ply:SetJumpPower(value)
        end
    end
})