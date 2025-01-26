local MODULE = MODULE

MODULE.Name = "Test Module"
MODULE.Description = "A test module."
MODULE.Author = "Riggs"

function MODULE:OnReloaded()
    print(self.Name .. " has been reloaded.")
end