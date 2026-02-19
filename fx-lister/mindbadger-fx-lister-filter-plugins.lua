-- @description Functions to perform the plugin filtering required by the fx-lister
-- @author Mindbadger
-- @noindex

function filterPlugins(plugins, filters)
    for _, plugin in pairs(plugins) do
        if plugin.name ~= nil and plugin.name ~= '' then
            local nameUpper = string.upper(plugin.name)
            local match = true
            
            if filters.searchTerm ~= nil and filters.searchTerm ~= '' then
                local searchUpper = string.upper(filters.searchTerm)
                local index = string.find(nameUpper, searchUpper)
                match = match and (index ~= nil and index > 0)
            end

            if filters.authorIndex ~= nil and Authors[filters.authorIndex] ~= "**ALL**" then
                -- Zero index = ALL, i.e. no filter on author
                local index = string.find(plugin.author, Authors[filters.authorIndex])
                match = match and (index ~= nil and index > 0)
            end

            if filters.showOnlyFavourites then
                match = match and plugin.favourite
            end

            if not filters.showUnused then
                match = match and not plugin.unused
            end

            if not filters.new then
                match = match and not plugin.new
            end

            if not filters.showRemoved then
                match = match and not plugin.removed and not plugin.demo
            end

            if filters.filterByTags then
                local filterTagsMap = {}
                for _, filterTag in pairs(filters.filterTags) do
                    filterTagsMap[filterTag.name] = filterTag.selected
                end

                if plugin.tags == nil then
                    match = false
                else
                    local matchingTags = false
                    for _, tag in pairs(plugin.tags) do
                        matchingTags = matchingTags or filterTagsMap[tag]
                    end
                    match = match and matchingTags
                end
            end

            plugin.hidden = not match
        end
    end

    return plugins
end
