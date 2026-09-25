local disconnectedPlayers = {}

AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src) or ('Player ' .. src)

    table.insert(disconnectedPlayers, 1, {
        name = name,
        slot = src,
        reason = reason or 'Unknown',
        time = os.date('%H:%M:%S')
    })

    if #disconnectedPlayers > Config.MaxDisconnected then
        table.remove(disconnectedPlayers, #disconnectedPlayers)
    end
end)

RegisterServerEvent('playerlist:requestData')
AddEventHandler('playerlist:requestData', function()
    local src = source
    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        table.insert(players, {
            name = GetPlayerName(playerId),
            slot = tonumber(playerId),
            ping = GetPlayerPing(playerId)
        })
    end

    if Config.SortBy == 'name' then
        table.sort(players, function(a, b) return (a.name or ''):lower() < (b.name or ''):lower() end)
    else
        table.sort(players, function(a, b) return a.slot < b.slot end)
    end

    TriggerClientEvent('playerlist:receiveData', src, players, #players)
end)

RegisterServerEvent('playerlist:requestDisconnected')
AddEventHandler('playerlist:requestDisconnected', function()
    local src = source
    TriggerClientEvent('playerlist:receiveDisconnected', src, disconnectedPlayers)
end)
