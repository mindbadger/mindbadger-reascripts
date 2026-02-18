-- @description The functions to support reaper track manipulation
-- @author Mindbadger
-- @version 1.0
-- @noindex

function AddPluginToSelectedTrack(pluginName, originalName)
    local selectedTrackIndex = 0
    local track = reaper.GetSelectedTrack(Project, selectedTrackIndex)

    while track ~= nil do
        local always_create_new_fx = -1
        
        local nameToAdd
        if originalName ~= nil and originalName ~= '' then
            nameToAdd = originalName
        else
            nameToAdd = pluginName
        end

        local trackIdx = reaper.TrackFX_AddByName(track, nameToAdd, false, always_create_new_fx)

        reaper.TrackFX_SetNamedConfigParm(track, trackIdx, "renamed_name", pluginName)

        local show_chain = 1
        reaper.TrackFX_Show(track, 0, show_chain)
        reaper.TrackFX_SetOpen(track, trackIdx, true)

        selectedTrackIndex = selectedTrackIndex + 1
        track = reaper.GetSelectedTrack(Project, selectedTrackIndex)
    end
end

function WeHaveASelectedTrack()
    local selectedTrackIndex = 0
    local track = reaper.GetSelectedTrack(Project, selectedTrackIndex)
    return track ~= nil
end
