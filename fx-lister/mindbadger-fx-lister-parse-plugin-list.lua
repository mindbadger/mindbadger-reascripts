function GetTagsFromPlugins(plugins)
    local tags = {}
    local tagsMap = {}
    for _, plugin in pairs(plugins) do
        local tagsForPlugin = plugin.tags

        if tagsForPlugin == nil then
            tagsForPlugin = {}
        end

        for _, tag in pairs(tagsForPlugin) do
            tagsMap[tag] = false
        end
    end

    for tag, selected in pairs(tagsMap) do
        tags[#tags+1] = {
            name = tag,
            selected = false -- false means deselected by default
        }
    end
    return tags
end

function GetAuthorsFromPlugins(plugins)
    local authors = {}
    local authorsMap = {}
    for _, plugin in pairs(plugins) do
        authorsMap[plugin.author] = true
    end

    authors[#authors+1] = "**ALL**"

    for author, _ in pairs(authorsMap) do
        if author ~= nil and author ~= '' then
            authors[#authors+1] = author
        end
    end

    table.sort(authors, function(a, b) return string.upper(a) < string.upper(b) end)
    return authors
end
