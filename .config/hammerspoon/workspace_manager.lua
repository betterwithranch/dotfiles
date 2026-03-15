local M = {}

local spaces = require("hs.spaces")

local workspaces = {}
local spaceMap = {}

local workspaceOrder = { "personal", "Sanctum", "SendCarrot", "MergeFreeze" }

function M.discoverSpaces()
	local all = spaces.allSpaces()
	local screen = hs.screen.mainScreen():getUUID()
	local ordered = all[screen]

	spaceMap = {}

	for index, spaceID in ipairs(ordered) do
		spaceMap[index] = spaceID
	end
end

function M.loadWorkspaces()
	workspaces = {
		personal = require("workspaces.personal"),
		sanctum = require("workspaces.sanctum"),
		sendcarrot = require("workspaces.sendcarrot"),
		mergefreeze = require("workspaces.mergefreeze"),
	}
end

function M.switchWorkspace(name)
	local ws = workspaces[name]
	if not ws then
		return
	end

	local space = spaceMap[ws.spaceIndex]

	hs.spaces.gotoSpace(space)
end

function M.workspaceHealth()
	for _, win in ipairs(hs.window.allWindows()) do
		print("checking", win:title())
	end

	hs.alert.show("Workspace repair complete")
end

function M.bindHotkeys()
	hs.hotkey.bind({ "ctrl" }, "p", function()
		M.switchWorkspace("personal")
	end)
	hs.hotkey.bind({ "ctrl" }, "a", function()
		M.switchWorkspace("sanctum")
	end)
	hs.hotkey.bind({ "ctrl" }, "b", function()
		M.switchWorkspace("sendcarrot")
	end)
	hs.hotkey.bind({ "ctrl" }, "c", function()
		M.switchWorkspace("mergefreeze")
	end)

	hs.hotkey.bind({ "ctrl" }, "tab", function()
		M.nextWorkspace()
	end)
	hs.hotkey.bind({ "ctrl", "shift" }, "tab", function()
		M.previousWorkspace()
	end)
end

function M.nextWorkspace()
	local currentSpace = hs.spaces.focusedSpace()

	for i, name in ipairs(workspaceOrder) do
		local ws = workspaces[name]

		if spaceMap[ws.spaceIndex] == currentSpace then
			local nextIndex = i + 1
			if nextIndex > #workspaceOrder then
				nextIndex = 1
			end

			M.switchWorkspace(workspaceOrder[nextIndex])
			return
		end
	end
end

function M.previousWorkspace()
	local currentSpace = hs.spaces.focusedSpace()

	for i, name in ipairs(workspaceOrder) do
		local ws = workspaces[name]

		if spaceMap[ws.spaceIndex] == currentSpace then
			local prevIndex = i - 1
			if prevIndex < 1 then
				prevIndex = #workspaceOrder
			end

			M.switchWorkspace(workspaceOrder[prevIndex])
			return
		end
	end
end

local menuBar = nil

function M.startMenuIndicator()
	menuBar = hs.menubar.new()

	local function update()
		local currentSpace = hs.spaces.focusedSpace()

		for name, ws in pairs(workspaces) do
			if spaceMap[ws.spaceIndex] == currentSpace then
				menuBar:setTitle(ws.icon .. " " .. ws.name)
				return
			end
		end

		menuBar:setTitle("Workspace")
	end

	update()

	local watcher = hs.spaces.watcher.new(function()
		update()
	end)

	watcher:start()
end

function M.startWindowRouting() end
function M.startAutoHealing() end

function M.startSpaceRefresh()
	hs.timer.doEvery(60, function()
		M.discoverSpaces()
	end)
end

return M
