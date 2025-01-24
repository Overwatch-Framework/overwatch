MODULE = {}

MODULE.Name = "Test Module"
MODULE.Description = "A test module."
MODULE.Author = "Riggs"

function MODULE:OnReloaded()
    print("Test Module has been reloaded.")
end

ow.modules.Register(MODULE)