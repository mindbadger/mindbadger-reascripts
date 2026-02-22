-- @description fx-lister window by TheMindbadger
-- @author Mindbadger
-- @version 1.3
-- @about
--    The main entry script to open the fx-lister.
--    This tool allows you to define metadata to describe your installed plugins and then be
--    able to use this to quickly search for the plugins you need quickly by filtering on this
--    metadata.
--    IMPORTANT: After adding metadata, make sure you back-up the
--               <YourUserHomeDirectory>\AppData\Roaming\REAPER\fx-metadata.json file 
-- @provides
--    [nomain] mindbadger-fx-lister-*.lua
-- @changelog
--   20 Feb 2026 - v 1.2 - improved the documentation
--   20 Feb 2026 - v 1.2.1 - re-published to fix broken link in README
--   22 Feb 2026 - v 1.3 - Fixed search to allow special characters

-- Initialise Global Variables
ScriptVersion = "0.1"
ScriptName = 'FX Lister'
Project = 0
ReaperPath = reaper.GetResourcePath()
NewTag = ''
InitialFocus = true
MoveFocusToPluginTable = false
FilterTagsNeedSort = false

-- Load ImGui Functions
dofile(ReaperPath .. '/Scripts/ReaTeam Extensions/API/imgui.lua')
  ('0.8.7.6') -- current version at the time of writing the script

package.path = package.path..';'..debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]] .. "?.lua;" -- GET DIRECTORY FOR REQUIRE

-- import required application functions
require('mindbadger-fx-lister-file-functions')
require('mindbadger-fx-lister-parse-plugin-list')
require('mindbadger-fx-lister-track-functions')
require('mindbadger-fx-lister-gui')

----------------------------------------------------------------------------------------
-- Main application code:

if WeHaveASelectedTrack() then
  -- read the main application data into global variables
  Plugins = ReadFxFromFileAndMergeWithInstalledFx()
  Tags = GetTagsFromPlugins(Plugins)
  Authors = GetAuthorsFromPlugins(Plugins)

  -- open the UI
  reaper.defer(Loop)
end
