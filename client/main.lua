local spraying = false
local sprayProp = nil

local function notify(description, nType)
    if lib and lib.notify then
        lib.notify({ description = description, type = nType or 'inform' })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(description)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

local function playSpraySound()
    SendNUIMessage({
        action = 'play',
        file = 'spraypaint.ogg',
        volume = 0.45,
    })
    if GetResourceState('interact-sound') == 'started' then
        TriggerEvent('InteractSound_CL:PlayOnOne', 'spraypaint', 0.5)
    end
end

local function loadModel(model)
    if not IsModelValid(model) then return false end
    RequestModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasModelLoaded(model)
end

local function attachSprayCan(ped)
    local model = `prop_cs_spray_can`
    if not loadModel(model) then return nil end
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.04, -70.0, 0.0, -10.0, true, true, false, false, 1, true)
    SetModelAsNoLongerNeeded(model)
    return prop
end

local function cleanupProp()
    if sprayProp and DoesEntityExist(sprayProp) then
        DeleteObject(sprayProp)
    end
    sprayProp = nil
    ClearPedTasks(PlayerPedId())
end

local function progress(opts)
    if lib and lib.progressBar then
        return lib.progressBar(opts)
    end
    Wait(opts.duration or 1000)
    return true
end

local function resolveTargetVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= 0 then
        if not Config.AllowInsideVehicle then
            return nil, 'notInVehicle'
        end
        if Config.RequireDriver and GetPedInVehicleSeat(vehicle, -1) ~= ped then
            return nil, 'notDriver'
        end
        return vehicle, nil, true
    end

    if not Config.AllowOutsideVehicle then
        return nil, 'notInVehicle'
    end

    local coords = GetEntityCoords(ped)
    local closest, closestDist
    if lib and lib.getClosestVehicle then
        closest, closestDist = lib.getClosestVehicle(coords, Config.OutsideMaxDistance, false)
    else
        closest = GetClosestVehicle(coords.x, coords.y, coords.z, Config.OutsideMaxDistance, 0, 70)
        if closest and closest ~= 0 then
            closestDist = #(coords - GetEntityCoords(closest))
        end
    end

    if not closest or closest == 0 or (closestDist and closestDist > Config.OutsideMaxDistance) then
        return nil, 'tooFar'
    end

    return closest, nil, false
end

local function sprayOutside(ped)
    local dict = 'switch@franklin@lamar_tagging_wall'
    sprayProp = attachSprayCan(ped)
    playSpraySound()

    local shook = progress({
        duration = Config.ShakeDuration,
        label = Config.Progress.shake,
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, combat = true, move = true },
        anim = { dict = dict, clip = 'lamar_tagging_wall_loop_lamar', flag = 1 },
    })

    if not shook then
        cleanupProp()
        return false
    end

    ClearPedTasks(ped)
    playSpraySound()

    local painted = progress({
        duration = Config.PaintDuration,
        label = Config.Progress.painting,
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, combat = true, move = true },
        anim = { dict = dict, clip = 'lamar_tagging_exit_loop_lamar', flag = 1 },
    })

    cleanupProp()
    return painted
end

local function sprayInside()
    playSpraySound()
    return progress({
        duration = Config.InsideDuration,
        label = Config.Progress.inside,
        useWhileDead = false,
        canCancel = true,
        disable = { combat = true, move = true },
    })
end

local function trySpray(paint, slot)
    if spraying then
        notify(Config.Notify.busy, 'error')
        return
    end
    if not paint then
        notify(Config.Notify.invalid, 'error')
        return
    end

    local vehicle, err, inside = resolveTargetVehicle()
    if not vehicle then
        notify(Config.Notify[err] or Config.Notify.notInVehicle, 'error')
        return
    end

    spraying = true
    local finished
    if inside then
        finished = sprayInside()
    else
        finished = sprayOutside(PlayerPedId())
    end

    if not finished then
        spraying = false
        notify(Config.Notify.cancelled, 'error')
        return
    end

    -- Re-resolve in case they walked away / swapped seats during the progress bar.
    vehicle, err = resolveTargetVehicle()
    if not vehicle then
        spraying = false
        notify(Config.Notify[err] or Config.Notify.tooFar, 'error')
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local plate = TrimPlate(GetVehicleNumberPlateText(vehicle))
    local color = GetPaintColorIndex(paint)

    TriggerServerEvent('djfivem-spraypaint:server:apply', {
        item = paint.item,
        slot = slot and slot.slot or nil,
        netId = netId,
        plate = plate,
        color = color,
    })

    spraying = false
end

RegisterNetEvent('djfivem-spraypaint:client:use', function(itemName, slot)
    trySpray(GetPaintByItem(itemName), { slot = slot })
end)

RegisterNetEvent('djfivem-spraypaint:client:applied', function(netId, color)
    local vehicle = NetToVeh(netId)
    if vehicle and vehicle ~= 0 then
        ApplyChameleonPaint(vehicle, color)
    end
    notify(Config.Notify.success, 'success')
end)

RegisterNetEvent('djfivem-spraypaint:client:notify', function(message, nType)
    notify(message, nType)
end)

-- ox_inventory client export used by install/ox_inventory_items.lua
exports('chameleonpaint', function(data, slot)
    trySpray(GetPaintByItem(data and data.name), slot)
end)

-- When hopping into a painted car, ask the server to restore from DB/KVP.
CreateThread(function()
    local lastVehicle = 0
    while true do
        Wait(500)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 and vehicle ~= lastVehicle then
            lastVehicle = vehicle
            local plate = TrimPlate(GetVehicleNumberPlateText(vehicle))
            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            TriggerServerEvent('djfivem-spraypaint:server:request', netId, plate)
        elseif vehicle == 0 then
            lastVehicle = 0
        end
    end
end)
