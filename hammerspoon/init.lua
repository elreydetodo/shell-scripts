--- Hammerspoon configuration, linked from ~/.hammerspoon/init.lua.
--
-- Rewrites GNOME-style cursor chords into the macOS chords that every app
-- understands natively. DefaultKeyBinding.dict does the same for Cocoa text
-- views, but apps that handle keys themselves never consult it. Chromium pages
-- with their own editors, such as Slack's message box, are the main case. This
-- layer catches those apps because it changes the key before the app sees it.
--
-- karabiner/rules.json holds the same rules for machines that run
-- Karabiner-Elements instead. The two MUST stay in step.

require("hs.ipc")

--- Apps that receive keys unchanged. Terminals map these keys themselves, in
-- the iTerm profile and the shell.
local passThrough = {
    ["co.zeit.hyper"] = true,
    ["co.zeit.hyperterm"] = true,
    ["com.apple.Terminal"] = true,
    ["com.googlecode.iterm2"] = true,
}

--- Browsers keep Home and End. Their native replacement, Command+Left/Right,
-- means Back and Forward outside a text field. DefaultKeyBinding.dict turns
-- Home and End into line movement inside text fields.
local browsers = {
    ["com.apple.Safari"] = true,
    ["com.google.Chrome"] = true,
    ["org.mozilla.firefox"] = true,
}

local code = hs.keycodes.map

--- The rewrites, keyed by the modifiers held and the key's code. Each entry
-- gives the modifiers and key code to send instead. Shift is not part of the
-- match. It passes through, so most rules also cover selecting. A rule marked
-- noShift does not apply with Shift held, because its macOS replacement means
-- something else with Shift. Those chords reach the app unchanged, and
-- DefaultKeyBinding.dict handles them.
local rules = {
    ["ctrl+" .. code.left] = { mods = { alt = true }, key = code.left },
    ["ctrl+" .. code.right] = { mods = { alt = true }, key = code.right },
    ["ctrl+" .. code.up] = { mods = { alt = true }, key = code.up, noShift = true },
    ["ctrl+" .. code.down] = { mods = { alt = true }, key = code.down, noShift = true },
    ["ctrl+" .. code.home] = { mods = { cmd = true }, key = code.up },
    ["ctrl+" .. code["end"]] = { mods = { cmd = true }, key = code.down },
    ["ctrl+" .. code.delete] = { mods = { alt = true }, key = code.delete, noShift = true },
    ["ctrl+" .. code.forwarddelete] = { mods = { alt = true }, key = code.forwarddelete, noShift = true },
    ["+" .. code.home] = { mods = { cmd = true }, key = code.left, notIn = browsers },
    ["+" .. code["end"]] = { mods = { cmd = true }, key = code.right, notIn = browsers },
}

-- The watchers, taps and timers below are globals. Lua would garbage collect a
-- local one and silently stop it.

--- The bundle ID of the frontmost app, kept current by a watcher so that the
-- key handler does not query it on every key.
local frontmost = hs.application.frontmostApplication():bundleID()

appWatcher = hs.application.watcher.new(function(_, event, app)
    if event == hs.application.watcher.activated and app then
        frontmost = app:bundleID()
    end
end)
appWatcher:start()

--- Builds the lookup key of a rule from an event's modifiers. Shift and the
-- Function flag, which arrow keys always carry, are left out.
local function ruleKey(flags, keyCode)
    local mods = {}
    for _, mod in ipairs({ "alt", "cmd", "ctrl" }) do
        if flags[mod] then table.insert(mods, mod) end
    end
    return table.concat(mods, "+") .. "+" .. keyCode
end

-- The handler returns false in every case, so the event always continues.
-- When a rule matches, it continues with the new key code and modifiers.
keyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp }, function(event)
    if passThrough[frontmost] then return false end
    local flags = event:getFlags()
    local rule = rules[ruleKey(flags, event:getKeyCode())]
    if not rule or (rule.notIn and rule.notIn[frontmost]) then return false end
    if rule.noShift and flags.shift then return false end

    local newFlags = { shift = flags.shift, fn = flags.fn }
    for mod in pairs(rule.mods) do newFlags[mod] = true end
    event:setKeyCode(rule.key)
    event:setFlags(newFlags)
    return false
end)
keyTap:start()

-- macOS disables an event tap whose handler is slow or which a secure input
-- field interrupts. This timer turns the tap back on.
keyTapWatchdog = hs.timer.doEvery(5, function()
    if not keyTap:isEnabled() then keyTap:start() end
end)

-- Reloads the configuration when this file changes. The path is resolved
-- because ~/.hammerspoon/init.lua is a link into the repository. The reload
-- waits a moment and skips a missing file, because git and some editors
-- delete a file before writing its replacement. A reload of a missing file
-- would leave Hammerspoon with no configuration at all.
local configFile = hs.fs.pathToAbsolute(hs.configdir .. "/init.lua")
configWatcher = hs.pathwatcher.new(configFile, function()
    hs.timer.doAfter(0.5, function()
        if hs.fs.attributes(configFile) then hs.reload() end
    end)
end)
configWatcher:start()
