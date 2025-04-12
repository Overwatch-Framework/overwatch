# SQLite Utility Library for the Overwatch Framework

This library provides a modular, extensible system to manage persistent data using SQLite in Garry's Mod. It allows schemas or plugins to dynamically register variables for any SQL table (like `users`, `characters`, etc.), and ensures the tables are created, loaded, and saved correctly with default values.

## 🌟 Features
- Dynamic variable registration for different tables.
- Default row generation with schema-defined defaults.
- Automatic table creation based on registered variables.
- Row loading with fallback to default insertion.
- Support for saving updated rows.
- Generalized for use across multiple systems, not just players.

---

## 🧠 How It Works
The system revolves around the concept of registering variables for a table. These variables define what kind of data the table should store. Once variables are registered, you can:

- Initialize the table.
- Load a row (e.g., for a user or character).
- Save updates to a row.

Each row is automatically populated with default values on first load.

---

## 🔧 API Usage

### Register a Variable
```lua
ow.sqlite:RegisterVar("characters", "xp", 0)
ow.sqlite:RegisterVar("users", "credits", 100)
```

### Initialize a Table
```lua
ow.sqlite:InitializeTable("characters")
ow.sqlite:InitializeTable("users")
```
This will create the table if it doesn't exist using the registered variables as schema.

### Load a Row
```lua
ow.sqlite:LoadRow("users", "steamid", ply:SteamID(), function(data)
    ply.databaseInfo = data
end)
```
This will either return an existing row or insert a default one.

### Save a Row
```lua
ow.sqlite:SaveRow("users", ply.databaseInfo, "steamid")
```
This saves the updated row into the database using the steamid as a unique key.

### Create Table with Custom Schema
```lua
ow.sqlite:InitializeTable("inventory", {
    id = "INTEGER PRIMARY KEY AUTOINCREMENT"
})
```
You can pass additional schema fields if necessary.

---

## 💡 Use Cases
- Storing user data like SteamID, credits, permissions.
- Character data like XP, stats, role, flags.
- Plugin support for adding new persistent variables without modifying core schema logic.
- Any other system requiring SQLite-backed persistence.

---

## 📁 Example: Character Plugin Adding Custom XP Field
```lua
PLUGIN.name = "XP System"
PLUGIN.author = "Riggs"

function PLUGIN:InitializedPlugins()
    ow.sqlite:RegisterVar("characters", "xp", 0)
end
```

In your character loading logic:
```lua
ow.sqlite:LoadRow("characters", "steamid", ply:SteamID(), function(data)
    ply.characterData = data
end)
```

To save:
```lua
ow.sqlite:SaveRow("characters", ply.characterData, "steamid")
```

---

## ✅ Benefits
- Easy to extend by other developers or plugins.
- Reduces need to manually manage tables and schema.
- Avoids schema conflicts and hardcoded SQL logic.
- Works for any number of systems or table types.
