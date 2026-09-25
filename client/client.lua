local isOpen = false
local currentTab = 'online'

local function sendConfig()
    SendNUIMessage({
        action = 'config',
        ui = Config.UI,
        text = Config.Text,
        showPing = Config.ShowPing,
        keys = {
            online = Config.TabControls.online.label,
            disconnected = Config.TabControls.disconnected.label
        }
    })
end

RegisterCommand(Config.Command, function()
    isOpen = not isOpen
    SetNuiFocus(isOpen, isOpen)
    if isOpen then
        sendConfig()
    end
    SendNUIMessage({ action = 'toggle', open = isOpen })
    if isOpen then
        currentTab = 'online'
        SendNUIMessage({ action = 'setTab', tab = 'online' })
        TriggerServerEvent('playerlist:requestData')
    end
end, false)

RegisterKeyMapping(Config.Command, Config.OpenKeyDescription, 'keyboard', Config.OpenKey)

RegisterNUICallback('close', function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('switchTab', function(data, cb)
    currentTab = data.tab
    if currentTab == 'online' then
        TriggerServerEvent('playerlist:requestData')
    else
        TriggerServerEvent('playerlist:requestDisconnected')
    end
    cb('ok')
end)

local onlineCtrl = Config.TabControls.online.control
local discCtrl = Config.TabControls.disconnected.control

CreateThread(function()
    while true do
        if isOpen then
            Wait(0)
            DisableControlAction(0, onlineCtrl, true)
            DisableControlAction(0, discCtrl, true)

            if IsDisabledControlJustPressed(0, onlineCtrl) then
                currentTab = 'online'
                SendNUIMessage({ action = 'setTab', tab = 'online' })
                TriggerServerEvent('playerlist:requestData')
            elseif IsDisabledControlJustPressed(0, discCtrl) then
                currentTab = 'disconnected'
                SendNUIMessage({ action = 'setTab', tab = 'disconnected' })
                TriggerServerEvent('playerlist:requestDisconnected')
            elseif IsControlJustPressed(0, Config.CloseControl) then
                isOpen = false
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'toggle', open = false })
            end
        else
            Wait(250)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(Config.AreaUpdateInterval)
        if isOpen then
            local myCoords = GetEntityCoords(PlayerPedId())
            local count = 0
            for _, playerId in ipairs(GetActivePlayers()) do
                if Config.IncludeSelfInArea or playerId ~= PlayerId() then
                    local ped = GetPlayerPed(playerId)
                    if ped and DoesEntityExist(ped) then
                        local dist = #(myCoords - GetEntityCoords(ped))
                        if dist <= Config.AreaRadius then
                            count = count + 1
                        end
                    end
                end
            end
            SendNUIMessage({ action = 'updateArea', count = count })
        end
    end
end)

RegisterNetEvent('playerlist:receiveData')
AddEventHandler('playerlist:receiveData', function(players, total)
    SendNUIMessage({ action = 'updateOnline', players = players, total = total })
end)

RegisterNetEvent('playerlist:receiveDisconnected')
AddEventHandler('playerlist:receiveDisconnected', function(players)
    SendNUIMessage({ action = 'updateDisconnected', players = players })
end)
