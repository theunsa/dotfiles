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

-- Directional focus within the currently visible native Space.
local focus = {
  h = hs.window.filter.focusWest,
  j = hs.window.filter.focusSouth,
  k = hs.window.filter.focusNorth,
  l = hs.window.filter.focusEast,
}

for key, callback in pairs(focus) do
  bind({ "alt" }, key, callback, true)
end

-- Native window placement. Ctrl-Alt keeps Alt-H/J/K/L dedicated to focus.
local units = {
  j = hs.geometry.unitrect(0, 0.5, 1, 0.5),
  k = hs.geometry.unitrect(0, 0, 1, 0.5),
  y = hs.geometry.unitrect(0, 0, 0.5, 0.5),
  u = hs.geometry.unitrect(0.5, 0, 0.5, 0.5),
  b = hs.geometry.unitrect(0, 0.5, 0.5, 0.5),
  n = hs.geometry.unitrect(0.5, 0.5, 0.5, 0.5),
}

for key, unit in pairs(units) do
  bind({ "ctrl", "alt" }, key, function()
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
  bind({ "ctrl", "alt" }, key, function()
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

bind({ "ctrl", "alt" }, "c", function()
  withFocusedWindow(function(window)
    window:centerOnScreen(nil, true)
  end)
end)

bind({ "ctrl", "alt" }, "f", function()
  withFocusedWindow(function(window)
    window:maximize()
  end)
end)

-- Move a window to another monitor while retaining its relative frame.
bind({ "ctrl", "alt" }, "m", function()
  withFocusedWindow(function(window)
    local nextScreen = window:screen():next()
    if nextScreen ~= window:screen() then
      window:moveToScreen(nextScreen, false, true, 0)
    end
  end)
end)

-- Native Mission Control owns Ctrl-1…5 for switching Desktops.

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
  bind({ "ctrl", "alt", "shift" }, tostring(desktop), function()
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
        return
      end

      -- JankyBorders misses private Space moves and leaves the old border
      -- behind. Its launchd job has KeepAlive, so a kill is a clean redraw.
      hs.task.new("/usr/bin/killall", nil, { "borders" }):start()
    end)
  end)
end

-- Launch or focus common applications. Native app-to-Desktop assignments
-- make macOS switch to the appropriate Space when the app is activated.
local applications = {
  t = "com.mitchellh.ghostty",
  b = "com.vivaldi.Vivaldi",
  a = "com.openai.codex",
  d = "com.electron.dockerdesktop",
  p = "com.apple.Preview",
  e = "com.apple.finder",
}

for key, bundleID in pairs(applications) do
  bind({ "alt" }, key, function()
    hs.application.launchOrFocusByBundleID(bundleID)
  end)
end

bind({ "alt" }, "return", function()
  hs.application.launchOrFocusByBundleID("com.mitchellh.ghostty")
end)

local keymap = [[
Alt-H/J/K/L       focus left/down/up/right
Ctrl-1…5          switch native Desktop
Alt-T/B/A/D/P/E   Ghostty/browser/Codex/Docker/Preview/Finder
Alt-Enter         focus or launch Ghostty
Ctrl-Alt-H/L      left/right; repeat for halves or thirds
Ctrl-Alt-J/K      bottom/top half
Ctrl-Alt-Y/U/B/N  screen quarters
Ctrl-Alt-C/F      centre/fill
Ctrl-Alt-M        move window to next monitor
Ctrl-Alt-Shift-1…5 send window to Desktop
]]

bind({ "alt" }, "/", function()
  hs.alert.show(keymap, 6)
end)

hs.alert.show("Hammerspoon shortcuts loaded")
