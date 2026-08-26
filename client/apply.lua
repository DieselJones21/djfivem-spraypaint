local applying = {}

local function debugPrint(...)
    if Config.Debug then
        print('[djfivem-spraypaint]', ...)
    end
end

function ApplyChameleonPaint(vehicle, color)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    color = tonumber(color)
    if not color then return false end

    if NetworkGetEntityIsNetworked(vehicle) then
        local owner = NetworkGetEntityOwner(vehicle)
        if owner ~= PlayerId() then
            NetworkRequestControlOfEntity(vehicle)
            local timeout = GetGameTimer() + 1000
            while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do
                NetworkRequestControlOfEntity(vehicle)
                Wait(0)
            end
        end
    end

    SetVehicleModKit(vehicle, 0)
    ClearVehicleCustomPrimaryColour(vehicle)
    ClearVehicleCustomSecondaryColour(vehicle)

    local _, secondary = GetVehicleColours(vehicle)
    if Config.PaintSecondary then
        SetVehicleColours(vehicle, color, color)
    else
        SetVehicleColours(vehicle, color, secondary)
    end

    debugPrint('applied', color, 'to', vehicle)
    return true
end

function VehicleHasColor(vehicle, color)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local primary = GetVehicleColours(vehicle)
    return tonumber(primary) == tonumber(color)
end

local function applyFromState(entity, color)
    if not color or entity == 0 then return end
    applying[entity] = color
    CreateThread(function()
        ApplyChameleonPaint(entity, color)
        Wait(500)
        if DoesEntityExist(entity) and applying[entity] == color then
            ApplyChameleonPaint(entity, color)
        end
        Wait(1500)
        if DoesEntityExist(entity) and applying[entity] == color then
            ApplyChameleonPaint(entity, color)
        end
    end)
end

AddStateBagChangeHandler('chameleonPaint', nil, function(bagName, _key, value)
    local entity = GetEntityFromStateBagName(bagName)
    local timeout = GetGameTimer() + 5000
    while (entity == 0 or not DoesEntityExist(entity)) and GetGameTimer() < timeout do
        Wait(50)
        entity = GetEntityFromStateBagName(bagName)
    end
    if entity == 0 or not DoesEntityExist(entity) then return end

    if value == nil or value == false then
        applying[entity] = nil
        ApplyChameleonPaint(entity, Config.RemoverDefaultPrimary or 0)
        return
    end

    applyFromState(entity, tonumber(value))
end)

-- Garage scripts often overwrite colour after spawn. Re-apply the saved chameleon.
CreateThread(function()
    while true do
        Wait(Config.KeepApplyingInterval or 2000)
        if Config.KeepApplying then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if vehicle ~= 0 then
                local color = Entity(vehicle).state.chameleonPaint
                if color and color ~= false and not VehicleHasColor(vehicle, color) then
                    ApplyChameleonPaint(vehicle, color)
                end
            end
        end
    end
end)

-- Vehicles that stream in already carrying the state bag (other players / garage spawn).
CreateThread(function()
    while true do
        Wait(4000)
        if Config.KeepApplying then
            local pedCoords = GetEntityCoords(PlayerPedId())
            local vehicles = GetGamePool('CVehicle')
            for i = 1, #vehicles do
                local vehicle = vehicles[i]
                if #(GetEntityCoords(vehicle) - pedCoords) <= 120.0 then
                    local color = Entity(vehicle).state.chameleonPaint
                    if color and color ~= false and not VehicleHasColor(vehicle, color) then
                        ApplyChameleonPaint(vehicle, color)
                    end
                end
            end
        end
    end
end)
