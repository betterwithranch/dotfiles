local wm = require("workspace_manager")

wm.discoverSpaces()
wm.loadWorkspaces()

wm.bindHotkeys()
wm.startWindowRouting()
wm.startAutoHealing()
wm.startMenuIndicator()
wm.startSpaceRefresh()

hs.hotkey.bind({"ctrl","alt","cmd"}, "R", function()
  hs.reload()
end)

hs.alert.show("Workspace OS loaded")
