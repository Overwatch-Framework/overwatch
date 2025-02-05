ow.character:RegisterVariable("name", {
    Type = ow.type.string,
    Field = "name",
    Default = "John Doe"
})

ow.character:RegisterVariable("description", {
    Type = ow.type.text,
    Field = "description",
    Default = "A mysterious person."
})

ow.character:RegisterVariable("model", {
    Type = ow.type.string,
    Field = "model",
    Default = "models/player/kleiner.mdl"
})

ow.character:RegisterVariable("money", {
    Type = ow.type.number,
    Field = "money",
    Default = 0
})