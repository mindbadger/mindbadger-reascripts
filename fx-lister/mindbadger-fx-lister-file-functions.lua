require('mindbadger-fx-lister-read-fx-map')
Json = require('mindbadger-fx-lister-rxi-json')

local fxMetadataFilePath = ReaperPath..'/fx-metadata.json'

local function savePluginMapToJsonFile(filePath, pluginMap)
    local serializedPluginMap = Json.encode(pluginMap)

    local file = assert(io.open(filePath, "w+"))
    assert(file:write(serializedPluginMap))
    file:close()
end

local function readJsonFileToPluginMap(filePath)
    local file = assert(io.open(filePath, "rb"))
    local rawFileContents = file:read("*all")
    file:close()

    return Json.decode(rawFileContents)
end

local function jsonFileExists(filePath)
    local file=io.open(filePath,"r")
    if file~=nil then io.close(file) return true else return false end
end

local function convertPluginMapToList(pluginMap)
    local plugins = {}
    for id, plugin in pairs(pluginMap) do
        if id ~= nil and plugin.name ~= nil then
            plugin.id = id
            plugin.hidden = nil
            plugins[#plugins+1] = plugin
        end
    end
    return plugins
end

local function convertPluginListToMap(pluginList)
    local pluginMap = {}
    for _, plugin in pairs(pluginList) do
        local id = plugin.id
        plugin.id = nil

        if plugin.originalName ~= nil and plugin.originalName ~= '' then
            plugin.displayName = plugin.name
            plugin.name = plugin.originalName
            plugin.originalName = nil
        else
            plugin.originalName = nil
            plugin.displayName = nil
        end

        plugin.hidden = nil

        -- Added to allow all plugins to be marked as uncategorised
        -- Then I can go through them one by one, categorise and rename them and remove the NOTCATEGORISED flag.
        -- if plugin.tags == nil then plugin.tags = {} end
        -- plugin.tags[#plugin.tags+1] = "NOTCATEGORISED"

        -- if plugin.author == 'Universal Audio' then
        --     plugin.unused = true
        -- end

        -- Added to allow NOTCATEGORISED to be removed from plugins identified as unusued
        -- if plugin.unused then
        --     for index, value in pairs(plugin.tags) do
        --         if value == "NOTCATEGORISED" then
        --             table.remove(plugin.tags, index)
        --         end
        --     end
        -- end

        pluginMap[id] = plugin
    end
    return pluginMap
end

function SaveFx(pluginList)
    local pluginMap = convertPluginListToMap(pluginList)
    savePluginMapToJsonFile(fxMetadataFilePath, pluginMap)
end

function ReadFxFromFileAndMergeWithInstalledFx()
    local currentFXMap
    if jsonFileExists(fxMetadataFilePath) then
        -- Read the existing file into a table
        -- The file is a map: id -> plugin details
        currentFXMap = readJsonFileToPluginMap(fxMetadataFilePath)
    else
        currentFXMap = {}
    end

    local pluginMap = ReadAndMergeFXMap(currentFXMap)
    savePluginMapToJsonFile(fxMetadataFilePath, pluginMap)

    local pluginList = convertPluginMapToList(pluginMap)

    return pluginList
end
