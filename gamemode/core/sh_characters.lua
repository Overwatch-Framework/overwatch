do
    ow.character:RegisterVariable("name", {
        Type = "string",
        Field = "name",
        Default = "John Doe"
    })

    ow.character:RegisterVariable("description", {
        Type = "text",
        Field = "description",
        Default = "A mysterious person."
    })

    ow.character:RegisterVariable("model", {
        Type = "string",
        Field = "model",
        Default = "models/player/kleiner.mdl"
    })
end