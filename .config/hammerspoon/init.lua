require("hs.ipc")

local workspace = require("workspace_manager")
workspace.init()

hs.hotkey.bind({ "ctrl", "alt", "cmd", "shift" }, "r", function()
	hs.reload()
end)

hs.alert.show("Workspace OS loaded")
