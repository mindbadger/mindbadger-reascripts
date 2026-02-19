-- @noindex

local lv

local function pluginHasTag(plugin, tag)
  if plugin.tags == nil then return false end
  for _, tagInPlugin in pairs(plugin.tags) do
    if tagInPlugin == tag then return true end
  end
  return false
end

local function getSelectedTagsFor(plugin)
  local selectedTags = {}
  for _, tag in pairs(Tags) do
    selectedTags[#selectedTags+1] = {
      name = tag.name,
      selected = pluginHasTag(plugin, tag.name)
    }
  end
  return selectedTags
end

local function applySelectedTagsToPlugin(selectedTags, plugin)
  local tagsForPlugin = {}
  for _, tag in pairs(selectedTags) do
    if tag.selected then
      tagsForPlugin[#tagsForPlugin+1] = tag.name
    end
  end
  plugin.tags = tagsForPlugin
end

function RenderEditModal(imGui, ctx, plugin)
  local key_chord = imGui.Mod_Ctrl | imGui.Key_C

  -- Always center this window when appearing
  local center_x, center_y = imGui.Viewport_GetCenter(imGui.GetWindowViewport(ctx))
  imGui.SetNextWindowPos(ctx, center_x, center_y, imGui.Cond_Appearing, 0.5, 0.5)
  imGui.SetNextWindowSize(ctx, 500, 600, reaper.ImGui_Cond_Once())

  local selectedTags = getSelectedTagsFor(plugin)

  if imGui.BeginPopupModal(ctx, 'Edit Plugin', nil, imGui.WindowFlags_None) then
    imGui.Separator(ctx)
    imGui.PushFont(ctx, nil, 16)

    local originalName
    local displayNameOverride
    local hadOverrideOnEntry = plugin.originalName ~= nil and plugin.originalName ~= ''
    if hadOverrideOnEntry then
        originalName = plugin.originalName
        displayNameOverride = plugin.name
    else
        originalName = plugin.name
        displayNameOverride = nil
    end

    imGui.TextWrapped(ctx, originalName)
    imGui.PopFont(ctx)
    imGui.Separator(ctx)
    imGui.TextWrapped(ctx, 'ID: '..plugin.id)
    imGui.TextWrapped(ctx, 'Author: '..plugin.author)
    imGui.TextWrapped(ctx, 'Type: '..plugin.type)
    imGui.Separator(ctx)

    _, plugin.favourite = imGui.Checkbox(ctx, 'Favourite',  plugin.favourite);
    imGui.SameLine(ctx); _, plugin.new = imGui.Checkbox(ctx, 'New',  plugin.new);
    imGui.SameLine(ctx); _, plugin.unused = imGui.Checkbox(ctx, 'Unused',  plugin.unused);    imGui.SameLine(ctx)
    imGui.SameLine(ctx); _, plugin.demo = imGui.Checkbox(ctx, 'Demo',  plugin.demo);
    imGui.SameLine(ctx); imGui.BeginDisabled(ctx, true); imGui.Checkbox(ctx, 'Removed',  plugin.removed); imGui.EndDisabled(ctx)

    _, displayNameOverride = imGui.InputText(ctx, 'Display Name:', displayNameOverride)

    if displayNameOverride ~= nil and displayNameOverride ~= '' then
        if hadOverrideOnEntry then
            -- We've already previously stored the original name and don't want to overwrite it
            plugin.name = displayNameOverride
        else
            plugin.originalName = plugin.name
            plugin.name = displayNameOverride
        end
    else
        if hadOverrideOnEntry then
            plugin.name = plugin.originalName
            plugin.originalName = nil
        end
    end

    local table_flags =
                  imGui.TableFlags_Sortable        |
                  imGui.TableFlags_Reorderable |
                  imGui.TableFlags_BordersOuter |
                  imGui.TableFlags_BordersV |
                  imGui.TableFlags_ScrollY

    -- Render the tags to select
    if imGui.BeginTable(ctx, 'selected_plugins_table', 2, table_flags, 450, 350, 0) then
      -- Declare columns
      imGui.TableSetupColumn(ctx, 'Tag', imGui.TableColumnFlags_WidthFixed, 300, 10)
      imGui.TableSetupColumn(ctx, '##selected', imGui.TableColumnFlags_NoSort | imGui.TableColumnFlags_WidthFixed , 20, 10)
      imGui.TableSetupScrollFreeze(ctx, 0, 1) -- Make row always visible
      imGui.TableHeadersRow(ctx)

      if imGui.TableNeedSort(ctx) or FilterTagForPluginNeedSort then
        table.sort(selectedTags, function(a, b) return string.upper(a.name) < string.upper(b.name) end)
        FilterTagForPluginNeedSort = false
      end

      for id, tag in pairs(selectedTags) do
        imGui.TableNextRow(ctx, nil)
        imGui.TableNextColumn(ctx)
        imGui.Text(ctx, tag.name)
        local label = '##'..tag.name
        imGui.TableNextColumn(ctx)
        _, selectedTags[id].selected = imGui.Checkbox(ctx, label,  selectedTags[id].selected);
      end

      applySelectedTagsToPlugin(selectedTags, plugin)

      imGui.EndTable(ctx)
    end
 
    _, NewTag = imGui.InputText(ctx, 'New Tag', NewTag)
    imGui.SameLine(ctx)
    if imGui.Button(ctx, 'Add') then
      Tags[#Tags+1] = {
        name = NewTag,
        selected = false
      }

      selectedTags[#selectedTags+1] = {
        name = NewTag,
        selected = true
      }
      applySelectedTagsToPlugin(selectedTags, plugin)
      NewTag = ''
      FilterTagForPluginNeedSort = true
      FilterTagsNeedSort = true
    end

    imGui.Separator(ctx)

    if imGui.Shortcut(ctx, key_chord, imGui.InputFlags_RouteFocused) then
        imGui.CloseCurrentPopup(ctx)
    end

    if imGui.Button(ctx, 'Close') then
      imGui.CloseCurrentPopup(ctx)
    end
    imGui.EndPopup(ctx)
  end
end
