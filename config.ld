project = "Overwatch"
title = "Overwatch documentation"
description = "A documentation for the Overwatch framework."
file = {
    "gamemode",
    "modules",
    exclude = {"gamemode/core/thirdparty"}
}
module_file = {
	Entity = "gamemode/core/meta/sh_entity.lua",
	Player = "gamemode/core/meta/sh_player.lua"
}
no_space_before_args = true
dir = "docs/html"
readme = "README.md"
style = "docs/css"
format = "markdown"
merge = true
strip_metamethod_prefix = true
no_viewed_topic_at_top = true
kind_names = {
    module = "Libraries",
    topic = "Manual",
    script = "Programs"
}

pretty_urls = true
pretty_topic_names = true

custom_tags = {
	{"realm", hidden = true},
	{"internal", hidden = true}
}

custom_display_name_handler = function(item, default_handler)
	if (item.type == "function" and item.module) then
		if (item.module.type == "classmod" or item.module.type == "panel") then
			return item.module.mod_name .. ":" .. default_handler(item)
		elseif (item.module.type == "hooks") then
			return item.module.mod_name:upper() .. ":" .. default_handler(item)
		end
	end

	return default_handler(item)
end

tparam_alias("string", "string")
tparam_alias("bool", "boolean")
tparam_alias("func", "function")
tparam_alias("player", "Player")
tparam_alias("entity", "Entity")
tparam_alias("color", "color")
tparam_alias("tab", "table")
tparam_alias("material", "material")
tparam_alias("vector", "vector")
tparam_alias("angle", "angle")