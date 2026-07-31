-- Native macOS owns Spaces and window state. Hammerspoon only supplies the
-- small, explicit keyboard layer that macOS is missing.
require("hs.ipc")

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

-- Native Mission Control owns Ctrl-1…5 for switching Desktops.

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
]]

bind({ "alt" }, "/", function()
  hs.alert.show(keymap, 6)
end)

hs.alert.show("Hammerspoon shortcuts loaded")
