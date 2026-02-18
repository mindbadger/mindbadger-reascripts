-- @description The functions to parse the plugin details from the details provided in Reaper
-- @author Mindbadger
-- @version 1.0
-- @noindex

local bracketedStringsToIgnore = {
    "%(mono%)",
    "%(%d+ch%)",
    "%(%d+%sout%)",
    "%(%d+%-%>%d+ch%)"
}

local function removeBracketedStringsToIgnore(pluginString)
    local remainingString = pluginString
    for _, stringToIgnore in pairs(bracketedStringsToIgnore) do
        local posOfStringToIgnore = string.find(remainingString, stringToIgnore)
        if posOfStringToIgnore and posOfStringToIgnore > 0 then
            remainingString = string.sub(remainingString, 1, posOfStringToIgnore-2)
        end
    end
    return remainingString
end

local function trim(s)
   return s:match( "^%s*(.-)%s*$" )
end

local function splitLastOccurrence(str, matchString)
    local index = str:match(".*()["..matchString.."]")

    local stringUpToLastCloseBracket = nil
    local stringAfterLastCloseBracket = nil
    if index and index > 0 then
        stringUpToLastCloseBracket = string.sub(str, 1, index-1)
        stringAfterLastCloseBracket = string.sub(str, index+1, string.len(str))
    end

    return index, stringUpToLastCloseBracket, stringAfterLastCloseBracket
end

local function getPluginAndAuthor(str)
    local author, pluginName

    local lastCBIndex, upToLastCB, afterLastCB = splitLastOccurrence(str, ")")

    if lastCBIndex and lastCBIndex > 0 then
        local lastOBIndex, upToLastOB, afterLastOB = splitLastOccurrence(upToLastCB, "(")
        -- We look for the penultimate close bracket to cater for plugins like this:
        -- "VST3: UADx Helios Type 69 Preamp and EQ (Universal Audio (UADx))"
        local penultCBIndex, upToPenultCB, afterPenultCB = splitLastOccurrence(upToLastCB, ")")

        if penultCBIndex and penultCBIndex > lastOBIndex then
            local penultOBIndex, upToPenultOB, afterPenultOB = splitLastOccurrence(upToLastOB, "(")
            pluginName = upToPenultOB
            author = afterPenultOB.."("..afterLastOB
        else
            pluginName = upToLastOB
            author = afterLastOB
        end
        return trim(pluginName), trim(author)
    end
    
    -- Should never get here, so this is a catch-all
    -- reaper.ShowConsoleMsg("Can't get plugin and author from: ["..str.."]\n")
    return 'UNKNOWN', 'UNKNOWN'
end

local function parsePlugin(pluginString)
    local firstColonPos = string.find(pluginString, ":")
    if firstColonPos then
        local type = string.sub(pluginString, 1, firstColonPos-1)
        local remainingString = string.sub(pluginString, firstColonPos+2)

        local name = ''
        local author = ''
        if type == "JS" then
            -- Reaper built-in plugins won't have an author in brackets
            name = remainingString
            author = "Reaper"
        else
            -- 3rd party plugins should have the author in brackets at the end of the string

            -- Some plugins have a postfixes in paranthesis - these need to be removed
            local nameAndAuthor = removeBracketedStringsToIgnore(remainingString)

            name, author = getPluginAndAuthor(nameAndAuthor)
        end

        return type, name, author
    end
end

local function resetRemovedFlagForAllPlugins(currentPluginMap)
    for _, plugin in pairs(currentPluginMap) do
        plugin.removed = true
    end
end

function ReadAndMergeFXMap(currentPluginMap)
    local retval = true
    local index = 0

    resetRemovedFlagForAllPlugins(currentPluginMap)

    while(retval)
    do
        local pluginDetails, ident, type, name, author
        retval, pluginDetails, ident = reaper.EnumInstalledFX(index)

        local nextRow = currentPluginMap[ident]

        if nextRow == nil then
            nextRow = {}
            nextRow.new = true
        end

        type, name, author = parsePlugin(pluginDetails)

        nextRow.type = type
        nextRow.author = author
        nextRow.removed = nil

        -- Map name and displayName into name and originalName
        -- This makes it easier for the application to treat overrides as the main value
        if nextRow.displayName ~= nil and nextRow.displayName ~= '' then
            nextRow.originalName = name
            nextRow.name = nextRow.displayName
            nextRow.displayName = nil
        else
            nextRow.originalName = nil
            nextRow.name = name
            nextRow.displayName = nil
        end

        currentPluginMap[ident] = nextRow

        index = index + 1
    end

    return currentPluginMap
end
