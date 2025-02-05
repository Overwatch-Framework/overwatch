ow.config:Register("frameworkColor", {
    DisplayName = "Framework Color",
    Description = "The color of the framework.",
    Type = "Color",
    Default = Color(0, 100, 150)
})

ow.config:Register("schemaColor", {
    DisplayName = "Schema Color",
    Description = "The color of the schema.",
    Type = "Color",
    Default = Color(0, 150, 100)
})

ow.config:Register("voiceDistance", {
    DisplayName = "Voice Distance",
    Description = "The distance that players can hear each other's voice.",
    Type = "Number",
    Default = 384
})

ow.config:Register("mainMenuMusic", {
    DisplayName = "Main Menu Music",
    Description = "The music that plays in the main menu.",
    Type = "String",
    Default = "music/hl2_song20_submix0.mp3"
})

ow.config:Register("menuCamPos", {
    DisplayName = "Menu Camera Position",
    Description = "The position of the camera in the main menu.",
    Type = "Vector",
    Default = vector_origin
})

ow.config:Register("menuCamAng", {
    DisplayName = "Menu Camera Angle",
    Description = "The angle of the camera in the main menu.",
    Type = "Angle",
    Default = angle_zero
})

ow.config:Register("menuCamFov", {
    DisplayName = "Menu Camera FOV",
    Description = "The field of view of the camera in the main menu.",
    Type = "Number",
    Default = 90
})

ow.config:Register("saveInterval", {
    DisplayName = "Save Interval",
    Description = "The interval at which all possible data is saved.",
    Type = "Number",
    Default = 300
})

ow.config:Register("walkSpeed", {
    DisplayName = "Walk Speed",
    Description = "The speed at which players walk.",
    Type = "Number",
    Default = 80,
    OnChange = function(value)
        for _, ply in player.Iterator() do
            ply:SetWalkSpeed(value)
        end
    end
})

ow.config:Register("runSpeed", {
    DisplayName = "Run Speed",
    Description = "The speed at which players run.",
    Type = "Number",
    Default = 180,
    OnChange = function(value)
        for _, ply in player.Iterator() do
            ply:SetRunSpeed(value)
        end
    end
})

ow.config:Register("jumpPower", {
    DisplayName = "Jump Power",
    Description = "The power at which players jump.",
    Type = "Number",
    Default = 160,
    OnChange = function(value)
        for _, ply in player.Iterator() do
            ply:SetJumpPower(value)
        end
    end
})

ow.config.server = ow.yaml.Read("gamemodes/overwatch/config.yml") or {}