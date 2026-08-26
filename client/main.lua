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

local function loadAnimDict(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(10)
    end
    return HasAnimDictLoaded(dict)
end

local function attachSprayCan(ped)
    local model = `prop_cs_spray_can`
    if not loadModel(model) then return nil end
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.04, -70.0, 0.0, -10.0, true, true, false, false, 1, true)
    SetModelAsNoLongerNeeded(model)
    return prop
end

local function cleanupProp()
    if sprayProp and DoesEntityExist(sprayProp) then
        DeleteObject(sprayProp)
    end
    sprayProp = nil
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
end

local function progress(opts)
    if lib and lib.progressBar then
        return lib.progressBar(opts)
    end
    Wait(opts.duration or 1000)
    return true
end

local function isFacingVehicle(ped, vehicle)
    if not Config.RequireFacingVehicle then return true end
    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(vehicle)
    return IsFacingTarget(GetEntityHeading(ped), pedCoords.x, pedCoords.y, vehCoords.x, vehCoords.y, Config.FacingMaxAngle)
end

local function faceVehicle(ped, vehicle)
    TaskTurnPedToFaceEntity(ped, vehicle, 800)
    Wait(700)
end

local function playSprayParticles(prop, duration)
    CreateThread(function()
        RequestNamedPtfxAsset('core')
        local timeout = GetGameTimer() + 2000
        while not HasNamedPtfxAssetLoaded('core') and GetGameTimer() < timeout do
            Wait(10)
        end
        local endsAt = GetGameTimer() + (duration or 2000)
        while sprayProp and DoesEntityExist(prop) and GetGameTimer() < endsAt do
            UseParticleFxAssetNextCall('core')
            StartNetworkedParticleFxNonLoopedOnEntity('ent_amb_steam', prop, 0.0, 0.15, 0.0, -80.0, 0.0, 0.0, 0.4, false, false, false)
            Wait(220)
        end
    end)
end

local function resolveTargetVehicle(opts)
    opts = opts or {}
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

    if not opts.ignoreFacing and not isFacingVehicle(ped, closest) then
        return nil, 'notFacing'
    end

    return closest, nil, false
end

local function sprayOutside(ped, vehicle, paintLabel, remover)
    faceVehicle(ped, vehicle)
    local dict = 'switch@franklin@lamar_tagging_wall'
    loadAnimDict(dict)
    sprayProp = attachSprayCan(ped)

    if not remover then
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
    end

    playSpraySound()
    playSprayParticles(sprayProp, remover and Config.RemoverDuration or Config.PaintDuration)

    local painted = progress({
        duration = remover and Config.RemoverDuration or Config.PaintDuration,
        label = remover and Config.Progress.removing or (paintLabel or Config.Progress.painting),
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, combat = true, move = true },
        anim = { dict = dict, clip = 'lamar_tagging_exit_loop_lamar', flag = 1 },
    })

    cleanupProp()
    return painted
end

local function sprayInside(remover)
    playSpraySound()
    return progress({
        duration = remover and Config.RemoverDuration or Config.InsideDuration,
        label = remover and Config.Progress.removing or Config.Progress.inside,
        useWhileDead = false,
        canCancel = true,
        disable = { combat = true, move = true },
    })
end

local function runUse(opts)
    opts = opts or {}
    if spraying then
        notify(Config.Notify.busy, 'error')
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
        finished = sprayInside(opts.remover)
    else
        finished = sprayOutside(PlayerPedId(), vehicle, opts.label, opts.remover)
    end

    if not finished then
        spraying = false
        notify(Config.Notify.cancelled, 'error')
        return
    end

    vehicle, err = resolveTargetVehicle({ ignoreFacing = true })
    if not vehicle then
        spraying = false
        notify(Config.Notify[err] or Config.Notify.tooFar, 'error')
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    local plate = TrimPlate(GetVehicleNumberPlateText(vehicle))

    if opts.remover then
        TriggerServerEvent('djfivem-spraypaint:server:remove', {
            item = Config.RemoverItem,
            slot = opts.slot,
            netId = netId,
            plate = plate,
        })
    else
        TriggerServerEvent('djfivem-spraypaint:server:apply', {
            item = opts.item,
            slot = opts.slot,
            netId = netId,
            plate = plate,
            color = opts.color,
        })
    end

    spraying = false
end

local function trySpray(paint, slot)
    if not paint then
        notify(Config.Notify.invalid, 'error')
        return
    end
    runUse({
        item = paint.item,
        slot = slot and slot.slot or nil,
        color = GetPaintColorIndex(paint),
        label = Config.Progress.painting,
        remover = false,
    })
end

local function tryRemove(slot)
    runUse({
        slot = slot and slot.slot or nil,
        remover = true,
    })
end

RegisterNetEvent('djfivem-spraypaint:client:use', function(itemName, slot)
    trySpray(GetPaintByItem(itemName), { slot = slot })
end)

RegisterNetEvent('djfivem-spraypaint:client:useRemover', function(slot)
    tryRemove({ slot = slot })
end)

RegisterNetEvent('djfivem-spraypaint:client:applied', function(netId, color)
    local vehicle = NetToVeh(netId)
    if vehicle and vehicle ~= 0 then
        ApplyChameleonPaint(vehicle, color)
    end
    notify(Config.Notify.success, 'success')
end)

RegisterNetEvent('djfivem-spraypaint:client:removed', function(netId, color)
    local vehicle = NetToVeh(netId)
    if vehicle and vehicle ~= 0 then
        ApplyChameleonPaint(vehicle, color)
    end
    notify(Config.Notify.removed, 'success')
end)

RegisterNetEvent('djfivem-spraypaint:client:notify', function(message, nType)
    notify(message, nType)
end)

exports('chameleonpaint', function(data, slot)
    trySpray(GetPaintByItem(data and data.name), slot)
end)

exports('paintremover', function(_data, slot)
    tryRemove(slot)
end)

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
