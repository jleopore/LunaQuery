package = "LunaQuery"
version = "0.9-1"
description = {
	summary = "Fluent, Linq-Style Query Expressions for Lua",
	detailed = [[
		This is an example for the LuaRocks tutorial.
		Here we would put a detailed, typically
		paragraph-long description.
 	]],
 	license = "MIT",
	homepage = "https://github.com/jleopore/LunaQuery"
}

dependencies = {
	"lua >= 5.1"
}

source = {
	url = "git://github.com/jleopore/LunaQuery.git",
  tag = "0.9"
}

build = {
	type = "builtin",
	modules = {
		LunaQuery = "LunaQuery.lua"
	}
}