local H = {}

--------------------------------------------------
-- Ghostty / tmux
--------------------------------------------------

function H.ensureGhosttySession(sessionName)
	for _, win in ipairs(hs.window.allWindows()) do
		local app = win:application()
		if app and app:name() == "Ghostty" then
			if win:title():lower():find(sessionName:lower()) then
				return
			end
		end
	end

	hs.task
		.new("/opt/homebrew/bin/ghostty", nil, {
			"--title",
			sessionName,
			"-e",
			"tmux attach -t " .. sessionName .. " || tmux new -s " .. sessionName,
		})
		:start()
end

--------------------------------------------------
-- Chrome profile resolver
--------------------------------------------------

local chromeProfiles = nil

local function shellQuote(value)
	return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function loadChromeProfiles()
	if chromeProfiles then
		return chromeProfiles
	end

	local path = os.getenv("HOME") .. "/Library/Application Support/Google/Chrome/Local State"

	local file = io.open(path, "r")

	if not file then
		return {}
	end

	local contents = file:read("*a")
	file:close()

	local ok, json = pcall(hs.json.decode, contents)

	if not ok then
		return {}
	end

	chromeProfiles = json.profile.info_cache or {}

	return chromeProfiles
end

--------------------------------------------------
-- Find profile directory by name/email
--------------------------------------------------

local function resolveChromeProfile(search)
	local profiles = loadChromeProfiles()

	search = search:lower()

	-- First pass: exact email match on standard profile dirs (Default, Profile N)
	for dir, info in pairs(profiles) do
		local email = (info.user_name or ""):lower()
		if email == search and dir:match("^[DP]") then
			return dir
		end
	end

	-- Second pass: exact email match on any dir
	for dir, info in pairs(profiles) do
		local email = (info.user_name or ""):lower()
		if email == search then
			return dir
		end
	end

	-- Third pass: substring match
	for dir, info in pairs(profiles) do
		local email = (info.user_name or ""):lower()
		if email:find(search, 1, true) then
			return dir
		end
	end

	return search
end

H.resolveChromeProfile = resolveChromeProfile

local function listChromeProcesses()
	local output = hs.execute("ps -Ao pid=,args= 2>/dev/null") or ""
	local processes = {}

	for line in output:gmatch("[^\r\n]+") do
		local pid, args = line:match("^%s*(%d+)%s+(.+)$")
		if pid and args and args:find("Google Chrome", 1, true) then
			table.insert(processes, {
				pid = tonumber(pid),
				args = args,
			})
		end
	end

	return processes
end

local function chromeProfilePIDs(profileDir)
	local wanted = "profile-directory=" .. profileDir
	local pids = {}

	for _, proc in ipairs(listChromeProcesses()) do
		if proc.args:find(wanted, 1, true) then
			table.insert(pids, proc.pid)
		end
	end

	return pids
end

local function chromeProfileApplications(profileDir)
	local apps = {}

	for _, pid in ipairs(chromeProfilePIDs(profileDir)) do
		local app = hs.application.applicationForPID(pid)
		if app then
			table.insert(apps, app)
		end
	end

	return apps
end

local function chromeProfileWindows(profileDir)
	local windows = {}

	for _, app in ipairs(chromeProfileApplications(profileDir)) do
		for _, win in ipairs(app:allWindows()) do
			if win and win:id() and win:role() == "AXWindow" then
				table.insert(windows, win)
			end
		end
	end

	return windows
end

local function moveWindowsToSpace(windows, spaceID)
	local moved = false

	for _, win in ipairs(windows) do
		local ok = hs.spaces.moveWindowToSpace(win, spaceID)
		if ok then
			moved = true
		end
	end

	return moved
end

local function moveExistingWindowsToSpace(profileDir, spaceID)
	local windows = chromeProfileWindows(profileDir)

	if #windows == 0 then
		return false
	end

	moveWindowsToSpace(windows, spaceID)

	return true
end

local function focusWindowsOnSpace(profileDir, spaceID)
	if not moveExistingWindowsToSpace(profileDir, spaceID) then
		return false
	end

	hs.spaces.gotoSpace(spaceID)

	hs.timer.doAfter(0.3, function()
		local refreshed = chromeProfileWindows(profileDir)
		local target = refreshed[1]
		if target then
			target:focus()
		end
	end)

	return true
end

local function launchChromeProfile(profileDir)
	return hs.execute(
		"open -na 'Google Chrome' --args --profile-directory="
			.. shellQuote(profileDir)
	)
end

--------------------------------------------------
-- Chrome profile detection (lsof-based)
--------------------------------------------------
function H.isChromeProfileRunning(profileDir)
	return #chromeProfilePIDs(profileDir) > 0
end

function H.ensureChromeProfile(profile, spaceID)
	local dir = resolveChromeProfile(profile)
	if not H.isChromeProfileRunning(dir) then
		launchChromeProfile(dir)
	end
end

function H.openChromeProfileOnSpace(profile, spaceID)
	local dir = resolveChromeProfile(profile)

	if moveExistingWindowsToSpace(dir, spaceID) then
		return true
	end

	launchChromeProfile(dir)

	local attempts = 0
	local maxAttempts = 40
	local timer

	timer = hs.timer.doEvery(0.25, function()
		attempts = attempts + 1

		if focusWindowsOnSpace(dir, spaceID) then
			timer:stop()
			return
		end

		if attempts >= maxAttempts then
			timer:stop()
			hs.alert.show("Chrome profile did not open: " .. profile)
		end
	end)

	return true
end

--------------------------------------------------
-- Generic launcher
--------------------------------------------------

function H.ensureWorkspaceApps(ws, spaceID)
	if ws.tmuxSession then
		H.ensureGhosttySession(ws.tmuxSession)
	end
end

return H
