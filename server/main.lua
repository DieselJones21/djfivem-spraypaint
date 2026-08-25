local function debugPrint(...)
    if Config.Debug then
        print('[djfivem-spraypaint]', ...)
    end
end

local function notify(src, message, nType)
    TriggerClientEvent('djfivem-spraypaint:client:notify', src, message, nType or 'error')
end

local function hasOxInventory()
    return GetResourceState('ox_inventory') == 'started'
end

local function getItemCount(src, item)
    if hasOxInventory() then
        return exports.ox_inventory:GetItemCount(src, item) or 0
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            local player = QBCore.Functions.GetPlayer(src)
            local data = player and player.Functions.GetItemByName(item)
            return data and (data.amount or data.count or 0) or 0
        end
    end

    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX then
            local player = ESX.GetPlayerFromId(src)
            local data = player and player.getInventoryItem(item)
            return data and (data.count or data.amount or 0) or 0
        end
    end

    return 0
end

local function removeItem(src, item, slot)
    if not Config.ConsumeOnSuccess then return true end

    if hasOxInventory() then
        return exports.ox_inventory:RemoveItem(src, item, 1, nil, slot) and true or false
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            local player = QBCore.Functions.GetPlayer(src)
            if not player then return false end
            player.Functions.RemoveItem(item, 1, slot)
            return true
        end
    end

    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX then
            local player = ESX.GetPlayerFromId(src)
            if not player then return false end
            player.removeInventoryItem(item, 1)
            return true
        end
    end

    return true
end

local function addItem(src, item, count)
    count = count or 1
    if hasOxInventory() then
        return exports.ox_inventory:AddItem(src, item, count)
    end
    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.AddItem(item, count)
            return true
        end
    end
    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        local player = ESX.GetPlayerFromId(src)
        if player then
            player.addInventoryItem(item, count)
            return true
        end
    end
    return false
end

local function isAdmin(src)
    if src == 0 then return true end
    for i = 1, #Config.AdminGroups do
        local group = Config.AdminGroups[i]
        if IsPlayerAceAllowed(src, group) then return true end
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            for i = 1, #Config.AdminGroups do
                if QBCore.Functions.HasPermission(src, Config.AdminGroups[i]) then
                    return true
                end
            end
        end
    end

    return false
end

local function vehicleNearPlayer(src, netId)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return nil end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        vehicle = GetVehiclePedIsIn(ped, false)
    end
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return nil end

    local dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    if dist > 8.0 then return nil end
    return vehicle
end

RegisterNetEvent('djfivem-spraypaint:server:apply', function(payload)
    local src = source
    payload = payload or {}

    local paint = GetPaintByItem(payload.item)
    if not paint then
        notify(src, Config.Notify.invalid, 'error')
        return
    end

    local expectedColor = GetPaintColorIndex(paint)
    if tonumber(payload.color) ~= tonumber(expectedColor) then
        debugPrint('color mismatch from', src, payload.color, expectedColor)
        payload.color = expectedColor
    end

    if getItemCount(src, paint.item) < 1 then
        notify(src, Config.Notify.noItem, 'error')
        return
    end

    local vehicle = vehicleNearPlayer(src, payload.netId)
    if not vehicle then
        notify(src, Config.Notify.tooFar, 'error')
        return
    end

    local ped = GetPlayerPed(src)
    if Config.RequireDriver and GetVehiclePedIsIn(ped, false) == vehicle then
        if GetPedInVehicleSeat(vehicle, -1) ~= ped then
            notify(src, Config.Notify.notDriver, 'error')
            return
        end
    end

    local plate = TrimPlate(GetVehicleNumberPlateText(vehicle))
    if plate == '' then
        plate = TrimPlate(payload.plate)
    end

    if not PlayerOwnsVehicle(src, plate) then
        notify(src, Config.Notify.notOwned, 'error')
        return
    end

    if not removeItem(src, paint.item, payload.slot) then
        notify(src, Config.Notify.noItem, 'error')
        return
    end

    SaveChameleonPaint(plate, expectedColor)
    Entity(vehicle).state:set('chameleonPaint', expectedColor, true)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    TriggerClientEvent('djfivem-spraypaint:client:applied', src, netId, expectedColor)
    debugPrint('saved', plate, expectedColor)
end)

RegisterNetEvent('djfivem-spraypaint:server:request', function(netId, plate)
    local src = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return end

    local realPlate = TrimPlate(GetVehicleNumberPlateText(vehicle))
    if realPlate == '' then realPlate = TrimPlate(plate) end

    local color = GetSavedColor(realPlate)
    if color then
        Entity(vehicle).state:set('chameleonPaint', color, true)
    end
end)

local function registerFrameworkUsables()
    if hasOxInventory() then return end

    if GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        for i = 1, #ChameleonPaints do
            local paint = ChameleonPaints[i]
            QBCore.Functions.CreateUseableItem(paint.item, function(source, item)
                TriggerClientEvent('djfivem-spraypaint:client:use', source, paint.item, item and item.slot)
            end)
        end
        print('[djfivem-spraypaint] registered qb-core usable items')
    end

    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        for i = 1, #ChameleonPaints do
            local paint = ChameleonPaints[i]
            ESX.RegisterUsableItem(paint.item, function(source)
                TriggerClientEvent('djfivem-spraypaint:client:use', source, paint.item)
            end)
        end
        print('[djfivem-spraypaint] registered ESX usable items')
    end
end

CreateThread(function()
    Wait(1000)
    registerFrameworkUsables()
end)

lib.addCommand('givechameleon', {
    help = 'Give a numbered chameleon spray (161-176)',
    params = {
        { name = 'number', type = 'number', help = 'Paint number 161-176' },
        { name = 'target', type = 'playerId', optional = true, help = 'Player id (default: you)' },
        { name = 'count', type = 'number', optional = true, help = 'Amount (default: 1)' },
    },
}, function(source, args)
    if source ~= 0 and not isAdmin(source) then
        notify(source, 'You cannot use this command.', 'error')
        return
    end

    local paint = GetPaintByNumber(args.number)
    if not paint then
        if source == 0 then
            print('Invalid paint number. Use 161-176.')
        else
            notify(source, 'Invalid paint number. Use 161-176.', 'error')
        end
        return
    end

    local target = args.target or source
    if not target or target == 0 then
        print('Specify a player id.')
        return
    end

    if addItem(target, paint.item, args.count or 1) then
        notify(target, ('Received %s'):format(DisplayItemLabel(paint)), 'success')
    else
        notify(source ~= 0 and source or target, 'Could not give item. Check inventory.', 'error')
    end
end)

lib.addCommand('chameleonpaints', {
    help = 'List numbered chameleon spray items',
}, function(source)
    local lines = {}
    for i = 1, #ChameleonPaints do
        local paint = ChameleonPaints[i]
        lines[#lines + 1] = ('#%s %s (%s)'):format(paint.number, paint.label, paint.item)
    end
    local text = table.concat(lines, '\n')
    if source == 0 then
        print(text)
    else
        notify(source, text, 'inform')
    end
end)

exports('GetSavedColor', GetSavedColor)
exports('SaveChameleonPaint', SaveChameleonPaint)
exports('GetPaints', function()
    return ChameleonPaints
end)
