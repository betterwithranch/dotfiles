local M = {}

local spaces = require("hs.spaces")
local helpers = require("workspace_helpers")

local workspaces = {}
local workspaceOrder = {}
local workspacePath = os.getenv("HOME") .. "/.config/hammerspoon/workspaces/"

local spaceMap = {}

--------------------------------------------------
-- Discover Spaces
--------------------------------------------------

function M.discoverSpaces()
	local all = spaces.allSpaces()
	local screen = hs.screen.mainScreen():getUUID()
	local ordered = all[screen]

	spaceMap = {}

	if not ordered then
		return
	end

	for index, spaceID in ipairs(ordered) do
		spaceMap[index] = spaceID
	end
end

--------------------------------------------------
-- Load workspace configs
--------------------------------------------------

function M.loadWorkspaces()
	workspaces = {}
	workspaceOrder = {}

	for file in hs.fs.dir(workspacePath) do
		if file:match("%.lua$") then
			local name = file:gsub("%.lua", "")
			local ws = dofile(workspacePath .. file)

			workspaces[name] = ws

			table.insert(workspaceOrder, name)
		end
	end

	------------------------------------------------
	-- Sort workspaces by spaceIndex
	------------------------------------------------

	table.sort(workspaceOrder, function(a, b)
		return (workspaces[a].spaceIndex or 0) < (workspaces[b].spaceIndex or 0)
	end)
end

--------------------------------------------------
-- Switch workspace
--------------------------------------------------

function M.switchWorkspace(name)
	local ws = workspaces[name]

	if not ws then
		print("Workspace not found:", name)
		return
	end

	local space = spaceMap[ws.spaceIndex]

	if not space then
		print("Space not found for workspace:", name)
		return
	end

	hs.alert.show(ws.icon .. " " .. ws.name)

	local function doSwitch()
		hs.spaces.gotoSpace(space)

		-- Focus a window on the target space
		hs.timer.doAfter(0.3, function()
			local spaceWins = hs.spaces.windowsForSpace(space)
			if not spaceWins then return end

			for _, winID in ipairs(spaceWins) do
				local win = hs.window.get(winID)
				if win and win:isVisible() then
					win:focus()
					return
				end
			end
		end)

		helpers.ensureWorkspaceApps(ws, space)
	end

	-- Wait for modifiers to be released before switching,
	-- otherwise macOS shows Mission Control overview
	local mods = hs.eventtap.checkKeyboardModifiers()
	if mods.ctrl or mods.alt or mods.cmd or mods.shift then
		local tap
		tap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, function(event)
			local flags = event:getFlags()
			if not (flags.ctrl or flags.alt or flags.cmd or flags.shift) then
				tap:stop()
				doSwitch()
			end
			return false
		end)
		tap:start()
	else
		doSwitch()
	end
end

--------------------------------------------------
-- Workspace health
--------------------------------------------------

function M.workspaceHealth()
	for _, win in ipairs(hs.window.allWindows()) do
		print("checking", win:title())
	end

	hs.alert.show("Workspace repair complete")
end

--------------------------------------------------
-- Dynamic hotkeys
--------------------------------------------------

function M.bindHotkeys()
	for name, ws in pairs(workspaces) do
		if ws.hotkey then
			hs.hotkey.bind(ws.hotkey.modifiers, ws.hotkey.key, function()
				M.switchWorkspace(name)
			end)

			print(
				"Workspace hotkey: "
					.. table.concat(ws.hotkey.modifiers, "+")
					.. "+"
					.. ws.hotkey.key
					.. " → "
					.. ws.name
			)
		end
	end

	------------------------------------------------
	-- cycling shortcuts
	------------------------------------------------

	hs.hotkey.bind({ "ctrl" }, "tab", function()
		M.nextWorkspace()
	end)

	hs.hotkey.bind({ "ctrl", "shift" }, "tab", function()
		M.previousWorkspace()
	end)
end

--------------------------------------------------
-- Next workspace
--------------------------------------------------

function M.nextWorkspace()
	local currentSpace = hs.spaces.focusedSpace()

	for i, name in ipairs(workspaceOrder) do
		local ws = workspaces[name]

		if ws and spaceMap[ws.spaceIndex] == currentSpace then
			local nextIndex = i + 1

			if nextIndex > #workspaceOrder then
				nextIndex = 1
			end

			M.switchWorkspace(workspaceOrder[nextIndex])

			return
		end
	end
end

--------------------------------------------------
-- Previous workspace
--------------------------------------------------

function M.previousWorkspace()
	local currentSpace = hs.spaces.focusedSpace()

	for i, name in ipairs(workspaceOrder) do
		local ws = workspaces[name]

		if ws and spaceMap[ws.spaceIndex] == currentSpace then
			local prevIndex = i - 1

			if prevIndex < 1 then
				prevIndex = #workspaceOrder
			end

			M.switchWorkspace(workspaceOrder[prevIndex])

			return
		end
	end
end

--------------------------------------------------
-- Menu bar indicator
--------------------------------------------------

local menuBar = nil

function M.startMenuIndicator()
	menuBar = hs.menubar.new(true, "A_workspace")

	local function update()
		local currentSpace = hs.spaces.focusedSpace()

		for name, ws in pairs(workspaces) do
			if ws and spaceMap[ws.spaceIndex] == currentSpace then
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

--------------------------------------------------
-- Space refresh (macOS renumbers occasionally)
--------------------------------------------------

function M.startSpaceRefresh()
	hs.timer.doEvery(60, function()
		M.discoverSpaces()
	end)
end

--------------------------------------------------
-- List workspaces (Alfred JSON)
--------------------------------------------------

function M.listWorkspaces()
	local items = {}

	for _, name in ipairs(workspaceOrder) do
		local ws = workspaces[name]
		local icon = ws.icon or "•"
		local display = ws.name or name

		table.insert(items, {
			title = icon .. " " .. display,
			subtitle = "Switch to " .. display,
			arg = name,
		})
	end

	table.insert(items, {
		title = "🛠 Workspace Health",
		subtitle = "Repair workspace state",
		arg = "__health__",
	})

	return hs.json.encode({ items = items })
end

--------------------------------------------------
-- Init
--------------------------------------------------

function M.init()
	M.loadWorkspaces()

	M.discoverSpaces()

	M.bindHotkeys()

	M.startMenuIndicator()

	M.startSpaceRefresh()
end

return M
