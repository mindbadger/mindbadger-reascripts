-- @description The main fx-lister window
-- @author Mindbadger
-- @noindex

require('mindbadger-fx-lister-filter-plugins')
require('mindbadger-fx-lister-gui-edit-modal')

package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua'
local ImGui = require 'imgui' '0.10'
local ctx = ImGui.CreateContext('FX Lister')
local key_chord = ImGui.Mod_Ctrl | ImGui.Key_C

local filters = {
  searchTerm = '',
  authorIndex = 1,
  showRemoved = false,
  showOnlyFavourites = true,
  showUnused = false,
  filterByTags = false,
  filterTags = {},
  new = true
}

local rv

-- Helper to display a little (?) mark which shows a tooltip when hovered.
-- In your own code you may want to display an actual icon if you are using a merged icon fonts (see docs/FONTS.md)
local function helpMarker(desc)
  ImGui.TextDisabled(ctx, '(?)')
  if ImGui.BeginItemTooltip(ctx) then
    ImGui.PushTextWrapPos(ctx, ImGui.GetFontSize(ctx) * 35.0)
    ImGui.Text(ctx, desc)
    ImGui.PopTextWrapPos(ctx)
    ImGui.EndTooltip(ctx)
  end
end

local function compareTableItems(a, b)
  for next_id = 0, math.huge do
    local ok, col_idx, col_user_id, sort_direction = ImGui.TableGetColumnSortSpecs(ctx, next_id)
    if not ok then break end

    local key

    if col_idx == 1 then
        key = 'name'
    else
        break
    end

    local is_ascending = sort_direction == ImGui.SortDirection_Ascending
    local aUpper = string.upper(a[key])
    local bUpper = string.upper(b[key])
    if aUpper < bUpper then
      return is_ascending
    elseif aUpper > bUpper then
      return not is_ascending
    end
  end

  -- table.sort is unstable so always return a way to differentiate items.
  -- Your own compare function may want to avoid fallback on implicit sort specs.
  -- e.g. a Name compare if it wasn't already part of the sort specs.
  return a.id < b.id
end

local function getWindowFlags()
  local window_flags = reaper.ImGui_WindowFlags_NoResize()
  return window_flags
end

local function renderAndHandleSearchBar()
  helpMarker("Type part of the name of the plugin you are looking for\nAlternatively, refine your search using the flags and tags below\n\nClick the + to the left of a plugin to add to add it to the selected tracks\nTo edit plugin details click the .. to the right of the plugin you want to add\n\nTo navigate to the plugin list, click CTRL+A, then use the arrow keys to navigate to the add or edit buttons. Hit SPACE to click the buttons\nTo close the window without adding plugins, click CTRL+C")
  ImGui.SameLine(ctx)

  if InitialFocus then ImGui.SetKeyboardFocusHere(ctx) end
  rv, filters.searchTerm = ImGui.InputTextWithHint(ctx, 'Search', 'find plugin by name', filters.searchTerm)
  InitialFocus = false
end

local function renderAndHandleTopFilterCheckboxes()
  rv, filters.showOnlyFavourites = ImGui.Checkbox(ctx, 'Only Favourites',  filters.showOnlyFavourites);

  local combo_preview_value = Authors[filters.authorIndex]
  local combo_flags = nil
  if ImGui.BeginCombo(ctx, 'Auth.', combo_preview_value, combo_flags) then
    for index, author in ipairs(Authors) do
        local is_selected = filters.authorIndex == index
        if ImGui.Selectable(ctx, Authors[index], is_selected) then
          filters.authorIndex = index
        end
        if is_selected then
          ImGui.SetItemDefaultFocus(ctx)
        end
    end
    ImGui.EndCombo(ctx)
  end

  rv, filters.filterByTags = ImGui.Checkbox(ctx, 'Filter Tags',  filters.filterByTags);
end

local function renderAndHandleBottomFilterCheckboxes()
  rv, filters.new = ImGui.Checkbox(ctx, 'New',  filters.new);
  rv, filters.showUnused = ImGui.Checkbox(ctx, 'Unused',  filters.showUnused);
  rv, filters.showRemoved = ImGui.Checkbox(ctx, 'Removed',  filters.showRemoved);
end

local function renderAndHandleTagsFilterTable()
  local table_flags =
                ImGui.TableFlags_Sortable        |
                ImGui.TableFlags_Hideable |
                ImGui.TableFlags_BordersOuter |
                ImGui.TableFlags_BordersV |
                ImGui.TableFlags_ScrollY

  --TODO: If filterByTags false, clear all tags ticks and disable

  if ImGui.BeginTable(ctx, 'table_tags', 2, table_flags, 160, 425) then
    -- Declare columns
    ImGui.TableSetupColumn(ctx, 'Tag', ImGui.TableColumnFlags_WidthFixed, 100)
    ImGui.TableSetupColumn(ctx, '##filtered', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 20)
    ImGui.TableSetupScrollFreeze(ctx, 0, 1) -- Make row always visible
    ImGui.TableHeadersRow(ctx)

    --Sort our data if sort specs have been changed!
    if ImGui.TableNeedSort(ctx) or FilterTagsNeedSort then
      table.sort(filters.filterTags, function(a, b) return string.upper(a.name) < string.upper(b.name) end)
      FilterTagsNeedSort = false
    end

    for id, tag in pairs(filters.filterTags) do
      ImGui.PushID(ctx, id)

      ImGui.TableNextRow(ctx, nil)

      ImGui.TableNextColumn(ctx)
      ImGui.Text(ctx, tag.name)

      ImGui.TableNextColumn(ctx)
      local label = '##'..tag.name
      rv, filters.filterTags[id].selected = ImGui.Checkbox(ctx, label, filters.filterTags[id].selected);

      ImGui.PopID(ctx)
    end

    ImGui.EndTable(ctx)
  end
end

local function renderAndHandlePluginsListTable(filteredPlugins)
  local windowOpen = true

  local table_flags =
                ImGui.TableFlags_Sortable        |
                ImGui.TableFlags_Hideable |
                ImGui.TableFlags_BordersOuter |
                ImGui.TableFlags_BordersV |
                ImGui.TableFlags_ScrollY

  if ImGui.BeginTable(ctx, 'plugins_table', 7, table_flags, 530, 580,100) then

    -- Declare columns
    ImGui.TableSetupColumn(ctx, '##Select', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 10, 10)
    ImGui.TableSetupColumn(ctx, 'Name', ImGui.TableColumnFlags_WidthFixed , 230, 10)
    ImGui.TableSetupColumn(ctx, '##Favourite', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 12, 10)
    ImGui.TableSetupColumn(ctx, 'Author', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 120, 10)
    ImGui.TableSetupColumn(ctx, 'Type', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 50, 10)
    ImGui.TableSetupColumn(ctx, '##Unused', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 12, 10)
    ImGui.TableSetupColumn(ctx, '##Edit', ImGui.TableColumnFlags_NoSort | ImGui.TableColumnFlags_WidthFixed, 10, 10)
    ImGui.TableSetupScrollFreeze(ctx, 0, 1) -- Make row always visible
    ImGui.TableHeadersRow(ctx)
    
    -- Sort our data if sort specs have been changed!
    if ImGui.TableNeedSort(ctx) then
      table.sort(Plugins, compareTableItems)
    end

    for index, item in pairs(Plugins) do
      if not item.hidden and item.name ~= nil then

        ImGui.PushID(ctx, item.id)
        ImGui.TableNextRow(ctx, nil)
        if MoveFocusToPluginTable then ImGui.SetKeyboardFocusHere(ctx); MoveFocusToPluginTable = false end
        ImGui.TableNextColumn(ctx)

        if not item.removed and not item.demo then
          local buttonName = "+##"..item.name..item.type
          if ImGui.Button(ctx, buttonName, 12, 18) then
            AddPluginToSelectedTrack(item.name, item.originalName)
            windowOpen = false
          end
        end

        ImGui.TableNextColumn(ctx)
        local nameColour
        if item.removed or item.demo then
          nameColour = 0xA4A4A4C8
        elseif item.originalName ~= nil and item.originalName ~= '' then
          nameColour = 0xFFFF00FF
        else
          nameColour = 0xFFFFFFFF
        end
        ImGui.TextColored(ctx, nameColour, item.name)

        ImGui.TableNextColumn(ctx)
        if item.new then
          ImGui.Text(ctx, '✨')
        elseif item.favourite then
          ImGui.Text(ctx, '❤️')
        end

        ImGui.TableNextColumn(ctx)
        ImGui.Text(ctx, item.author)

        ImGui.TableNextColumn(ctx)
        ImGui.Text(ctx, item.type)

        ImGui.TableNextColumn(ctx)
        if item.unused then
          ImGui.Text(ctx, '👎')
        end

        ImGui.TableNextColumn(ctx)

        if not item.removed then
          local buttonName = "..##"..item.name..item.type
          if ImGui.Button(ctx, buttonName, 18, 18) then
            ImGui.OpenPopup(ctx, 'Edit Plugin')
          end
        end

        RenderEditModal(ImGui, ctx, item)

        ImGui.PopID(ctx)
      end
    end

    ImGui.EndTable(ctx)

    return windowOpen
  end
end

----------------------------------------------------------------------------------------
--- MAIN LOOP
----------------------------------------------------------------------------------------
function Loop()
  filters.filterTags = Tags

  if ImGui.IsKeyDown(ctx, 546) and ImGui.IsKeyDown(ctx, ImGui.Mod_Ctrl) then
    MoveFocusToPluginTable = true
  end

  -- Prepare the Window
  ImGui.SetNextWindowSize(ctx, 750, 660, reaper.ImGui_Cond_Once())

  -- OPEN THE WINDOW
  local visible, open = ImGui.Begin(ctx, 'FX Lister', true, getWindowFlags())

  if visible then
    if ImGui.Shortcut(ctx, key_chord, ImGui.InputFlags_RouteGlobal) then
      open = false
    end

    renderAndHandleSearchBar()

    if ImGui.BeginChild(ctx, 'ChildL', ImGui.GetContentRegionAvail(ctx) * 0.25, 598, ImGui.ChildFlags_Borders | ImGui.ChildFlags_NavFlattened, nil) then
      -- Left Hand Filters Bar
      renderAndHandleTopFilterCheckboxes()
      renderAndHandleTagsFilterTable()
      renderAndHandleBottomFilterCheckboxes()

      ImGui.EndChild(ctx)
    end

    -- After handling each filter, reduce the list 
    Plugins = filterPlugins(Plugins, filters)

    ImGui.SameLine(ctx)

    if ImGui.BeginChild(ctx, 'ChildR', 0, 598, ImGui.ChildFlags_Borders | ImGui.ChildFlags_NavFlattened, nil) then
      -- Right Hand Plugin List
      open = open and renderAndHandlePluginsListTable(Plugins)

      ImGui.EndChild(ctx)
    end

    ImGui.End(ctx)
  end
  if open then
    reaper.defer(Loop)
  else
    SaveFx(Plugins)
  end
end
