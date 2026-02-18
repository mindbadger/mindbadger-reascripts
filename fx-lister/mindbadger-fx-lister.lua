-- @description The main entry file for the fx-lister
-- @author Mindbadger
-- @version 1.0

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
