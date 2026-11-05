-- Native macOS owns Spaces and window state. Hammerspoon only supplies the
-- small, explicit keyboard layer that macOS is missing.
require("hs.ipc")
local spaces = require("hs.spaces")

hs.window.animationDuration = 0
hs.autoLaunch(true)

-- Watch the Stow source because filesystem events don't traverse the symlink.
local configSource = os.getenv("HOME") .. "/dotfiles/hammerspoon/.hammerspoon"
if not hs.fs.attributes(configSource) then
  configSource = hs.configdir
end
local configWatcher = hs.pathwatcher.new(configSource, hs.reload)
configWatcher:start()

local function bind(modifiers, key, callback, repeatable)
  hs.hotkey.bind(modifiers, key, callback, nil, repeatable and callback or nil)
end

local function withFocusedWindow(callback)
  local window = hs.window.focusedWindow()
  if window then
    callback(window)
  end
end

-- Briefly outline the window that receives focus. Unlike a persistent border
-- tool, nothing stays on screen or hooks WindowServer between key presses.
local flash
local function flashWindow(window)
  if flash then
    flash:delete()
  end

  local current = hs.canvas.new(window:frame())
  current:appendElements({
    type = "rectangle",
    action = "stroke",
    strokeColor = { hex = "#88c0d0" },
    strokeWidth = 6,
    roundedRectRadii = { xRadius = 10, yRadius = 10 },
  })
  current:level(hs.canvas.windowLevels.overlay)
  current:show()
  flash = current

  hs.timer.doAfter(0.3, function()
    if flash == current then
      current:delete()
      flash = nil
    end
  end)
end

-- Directional focus within the currently visible native Space. This mirrors
-- hs.window.filter.focusWest and friends, but keeps the target to flash it.
local focusWindows = hs.window.filter.defaultCurrentSpace
local focus = { h = "West", j = "South", k = "North", l = "East" }

for key, direction in pairs(focus) do
  bind({ "alt" }, key, function()
    for _, window in ipairs(focusWindows["windowsTo" .. direction](focusWindows, nil, nil, true) or {}) do
      if window:focus() then
        flashWindow(window)
        return
      end
    end
  end, true)
end

-- Native window placement. Alt focuses a window; Alt-Shift moves it, the same
-- split as Omarchy/i3/AeroSpace (Super goes there, Super-Shift takes it along).
local units = {
  j = hs.geometry.unitrect(0, 0.5, 1, 0.5),
  k = hs.geometry.unitrect(0, 0, 1, 0.5),
  -- Quarters: U I / N M form a square under the right hand's home position.
  u = hs.geometry.unitrect(0, 0, 0.5, 0.5),
  i = hs.geometry.unitrect(0.5, 0, 0.5, 0.5),
  n = hs.geometry.unitrect(0, 0.5, 0.5, 0.5),
  m = hs.geometry.unitrect(0.5, 0.5, 0.5, 0.5),
}

for key, unit in pairs(units) do
  bind({ "alt", "shift" }, key, function()
    withFocusedWindow(function(window)
      window:moveToUnit(unit)
    end)
  end)
end

local horizontalCycles = {
  h = {
    hs.geometry.unitrect(0, 0, 0.5, 1),
    hs.geometry.unitrect(0, 0, 2 / 3, 1),
    hs.geometry.unitrect(0, 0, 1 / 3, 1),
  },
  l = {
    hs.geometry.unitrect(0.5, 0, 0.5, 1),
    hs.geometry.unitrect(2 / 3, 0, 1 / 3, 1),
    hs.geometry.unitrect(1 / 3, 0, 2 / 3, 1),
  },
}

local function currentUnit(window)
  local frame = window:frame()
  local screen = window:screen():frame()
  return {
    x = (frame.x - screen.x) / screen.w,
    y = (frame.y - screen.y) / screen.h,
    w = frame.w / screen.w,
    h = frame.h / screen.h,
  }
end

local function approximatelyEqual(left, right)
  local tolerance = 0.02
  return math.abs(left.x - right.x) < tolerance
    and math.abs(left.y - right.y) < tolerance
    and math.abs(left.w - right.w) < tolerance
    and math.abs(left.h - right.h) < tolerance
end

for key, cycle in pairs(horizontalCycles) do
  bind({ "alt", "shift" }, key, function()
    withFocusedWindow(function(window)
      local current = currentUnit(window)
      local target = cycle[1]

      for index, unit in ipairs(cycle) do
        if approximatelyEqual(current, unit) then
          target = cycle[index % #cycle + 1]
          break
        end
      end

      window:moveToUnit(target)
    end)
  end)
end

bind({ "alt", "shift" }, "c", function()
  withFocusedWindow(function(window)
    window:centerOnScreen(nil, true)
  end)
end)

bind({ "alt", "shift" }, "f", function()
  withFocusedWindow(function(window)
    window:maximize()
  end)
end)

-- Move a window to another monitor while retaining its relative frame.
bind({ "alt", "shift" }, "o", function()
  withFocusedWindow(function(window)
    local nextScreen = window:screen():next()
    if nextScreen ~= window:screen() then
      window:moveToScreen(nextScreen, false, true, 0)
    end
  end)
end)

-- Native Mission Control owns Alt-1…5 for switching Desktops (set them in
-- System Settings → Keyboard → Keyboard Shortcuts → Mission Control).

-- Send the focused window to Desktop 1…5 without following it. Full-screen
-- application spaces are excluded so the numbers match ordinary Desktops.
local function userSpacesForScreen(screen)
  local result = {}
  local screenSpaces, errorMessage = spaces.spacesForScreen(screen)

  if not screenSpaces then
    return nil, errorMessage
  end

  for _, spaceID in ipairs(screenSpaces) do
    if spaces.spaceType(spaceID) == "user" then
      table.insert(result, spaceID)
    end
  end

  return result
end

for desktop = 1, 5 do
  bind({ "alt", "shift" }, tostring(desktop), function()
    withFocusedWindow(function(window)
      local desktopSpaces, errorMessage = userSpacesForScreen(window:screen())
      local targetSpace = desktopSpaces and desktopSpaces[desktop]

      if not targetSpace then
        hs.alert.show(errorMessage or ("Desktop " .. desktop .. " is not available on this display"))
        return
      end

      for _, currentSpace in ipairs(spaces.windowSpaces(window) or {}) do
        if currentSpace == targetSpace then
          return
        end
      end

      -- moveWindowToSpace uses a private API that can report success on
      -- recent macOS releases without moving anything, so confirm the result.
      local moved, moveError = spaces.moveWindowToSpace(window, targetSpace)
      local landed = false
      for _, currentSpace in ipairs(spaces.windowSpaces(window) or {}) do
        if currentSpace == targetSpace then
          landed = true
          break
        end
      end

      if not (moved and landed) then
        hs.alert.show(moveError or ("Could not move window to Desktop " .. desktop))
      end
    end)
  end)
end

-- Launch or focus common applications. Native app-to-Desktop assignments
-- make macOS switch to the appropriate Space when the app is activated.
-- Keep Alt-E/I/U/N/` free: macOS uses them as accent keys (é ê ë ñ è).
local applications = {
  t = "com.mitchellh.ghostty",
  a = "com.openai.codex",
  p = "com.apple.Preview",
  f = "com.apple.finder",
}

for key, bundleID in pairs(applications) do
  bind({ "alt" }, key, function()
    hs.application.launchOrFocusByBundleID(bundleID)
  end)
end

-- Chrome profiles. Alt-B opens a short-lived mode: 1/2/3 jumps to that
-- profile's most recent window (opening one if none exists), B goes to the
-- last Chrome window, and P/N step through the profiles (repeatable). The mode
-- ends after a choice, on Esc, or after two idle seconds.
-- Chrome window titles end with "– <profile>" or "(<profile>)".
local chromeProfiles = {
  { name = "Theuns", directory = "Profile 12" },
  { name = "Albertec", directory = "Default" },
  { name = "Plumb Line", directory = "Profile 19" },
}
-- A long-lived filter also tracks Chrome windows on other Desktops.
local chromeWindows = hs.window.filter.new(false):setAppFilter("Google Chrome", {})

local function chromeProfileIndex(window)
  local title = window and window:title() or ""
  for index, profile in ipairs(chromeProfiles) do
    for _, suffix in ipairs({ "– " .. profile.name, "(" .. profile.name .. ")" }) do
      if title:sub(-#suffix) == suffix then
        return index
      end
    end
  end
end

-- Chrome's Profiles menu focuses the profile's last window on any Desktop, or
-- opens one. Menu items read "<profile>" or "<account> (<profile>)".
local function selectChromeProfileMenu(chrome, name)
  for _, menu in ipairs(chrome:getMenuItems() or {}) do
    if menu.AXTitle == "Profiles" then
      for _, item in ipairs(menu.AXChildren and menu.AXChildren[1] or {}) do
        local title = item.AXTitle or ""
        if title == name or title:sub(-(#name + 2)) == "(" .. name .. ")" then
          return chrome:selectMenuItem({ "Profiles", title })
        end
      end
    end
  end
end

local chromeCurrent
local function focusChromeProfile(index)
  chromeCurrent = index
  local profile = chromeProfiles[index]

  -- Fast path: a window Hammerspoon already knows about.
  for _, window in ipairs(chromeWindows:getWindows(hs.window.filter.sortByFocusedLast)) do
    if chromeProfileIndex(window) == index then
      window:focus()
      return
    end
  end

  -- Hammerspoon only learns windows on other Desktops once they have been
  -- visible since it loaded, so let Chrome find (or create) the window.
  local chrome = hs.application.get("com.google.Chrome")
  if chrome and selectChromeProfileMenu(chrome, profile.name) then
    return
  end

  local directory = "--profile-directory=" .. profile.directory
  hs.task.new("/usr/bin/open", nil, { "-na", "Google Chrome", "--args", directory }):start()
end

local function stepChromeProfile(step)
  local current = chromeCurrent or chromeProfileIndex(hs.window.focusedWindow())
  if not current then
    current = step > 0 and 0 or 1
  end
  focusChromeProfile((current - 1 + step) % #chromeProfiles + 1)
end

local chromeMode = hs.hotkey.modal.new({ "alt" }, "b")
local chromeModeTimeout = hs.timer.delayed.new(2, function()
  chromeMode:exit()
end)
local chromeModeAlert

function chromeMode:entered()
  chromeCurrent = nil
  local labels = {}
  for index, profile in ipairs(chromeProfiles) do
    table.insert(labels, index .. " " .. profile.name)
  end
  chromeModeAlert = hs.alert.show("Chrome:  " .. table.concat(labels, "   ") .. "   B last   P/N step", 2)
  chromeModeTimeout:start()
end

function chromeMode:exited()
  chromeModeTimeout:stop()
  if chromeModeAlert then
    hs.alert.closeSpecific(chromeModeAlert)
    chromeModeAlert = nil
  end
end

local function chromeAction(callback, stayInMode)
  return function()
    callback()
    if stayInMode then
      chromeModeTimeout:start()
    else
      chromeMode:exit()
    end
  end
end

for index in ipairs(chromeProfiles) do
  chromeMode:bind({}, tostring(index), chromeAction(function()
    focusChromeProfile(index)
  end))
end

chromeMode:bind({}, "b", chromeAction(function()
  hs.application.launchOrFocusByBundleID("com.google.Chrome")
end))
chromeMode:bind({}, "n", chromeAction(function()
  stepChromeProfile(1)
end, true))
chromeMode:bind({}, "p", chromeAction(function()
  stepChromeProfile(-1)
end, true))
chromeMode:bind({}, "escape", function()
  chromeMode:exit()
end)

bind({ "alt" }, "return", function()
  hs.application.launchOrFocusByBundleID("com.mitchellh.ghostty")
end)

local keymap = [[
Alt-H/J/K/L        focus left/down/up/right
Alt-1…5            switch native Desktop
Alt-T/A/P/F        Ghostty/Codex/Preview/Finder
Alt-B then 1/2/3   Chrome: Theuns/Albertec/Plumb Line
Alt-B then B, P/N  Chrome: last window, prev/next profile
Alt-Enter          focus or launch Ghostty
Alt-Shift-H/L      left/right; repeat for halves or thirds
Alt-Shift-J/K      bottom/top half
Alt-Shift-U/I/N/M  screen quarters
Alt-Shift-C/F      centre/fill
Alt-Shift-O        move window to other monitor
Alt-Shift-1…5      send window to Desktop
]]

bind({ "alt" }, "/", function()
  hs.alert.show(keymap, 6)
end)

hs.alert.show("Hammerspoon shortcuts loaded")
