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

--------------------------------------------------
-- Chrome profile detection (lsof-based)
--------------------------------------------------
function H.isChromeProfileRunning(profileDir)
	local output = hs.execute(
		"lsof -c 'Google Chrome' 2>/dev/null | grep -q 'Google/Chrome/" .. profileDir .. "/' && echo yes"
	)
	return output ~= nil and output:find("yes") ~= nil
end

function H.ensureChromeProfile(profile, spaceID)
	local dir = resolveChromeProfile(profile)
	if not H.isChromeProfileRunning(dir) then
		hs.execute(
			"open -na 'Google Chrome' --args --profile-directory='" .. dir .. "'"
		)
	end
end

--------------------------------------------------
-- Generic launcher
--------------------------------------------------

function H.ensureWorkspaceApps(ws, spaceID)
	if ws.tmuxSession then
		H.ensureGhosttySession(ws.tmuxSession)
	end

	if ws.chromeProfile then
		H.ensureChromeProfile(ws.chromeProfile, spaceID)
	end
end

return H
