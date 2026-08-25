local cache = {}
local tableReady = false

local function sqlAvailable()
    return GetResourceState('oxmysql') == 'started'
end

local function dbQuery(statement, params)
    if not sqlAvailable() then return {} end
    local ok, result = pcall(function()
        return exports.oxmysql:query_async(statement, params)
    end)
    if not ok then
        print('[djfivem-spraypaint] SQL query failed:', result)
        return {}
    end
    return result or {}
end

local function dbExec(statement, params)
    if not sqlAvailable() then return end
    local ok, err = pcall(function()
        exports.oxmysql:execute_async(statement, params)
    end)
    if not ok then
        print('[djfivem-spraypaint] SQL execute failed:', err)
    end
end

local function kvpKey(plate)
    return 'paint:' .. PlateKey(plate)
end

function GetSavedColor(plate)
    local key = PlateKey(plate)
    if key == '' then return nil end
    if cache[key] then return cache[key] end

    local stored = GetResourceKvpString(kvpKey(plate))
    if stored and stored ~= '' then
        local color = tonumber(stored)
        if color then
            cache[key] = color
            return color
        end
    end

    return nil
end

local function decodeProps(raw)
    if type(raw) == 'table' then return raw end
    if type(raw) ~= 'string' or raw == '' then return nil end
    local ok, props = pcall(json.decode, raw)
    if ok and type(props) == 'table' then return props end
    return nil
end

local function patchColor(props, color)
    if not props then return nil end
    props.color1 = color
    if Config.PaintSecondary then
        props.color2 = color
    end
    return props
end

local function updateOwnedVehicleRow(tableName, column, plate, color)
    local key = PlateKey(plate)
    local rows = dbQuery(
        ('SELECT `%s` FROM `%s` WHERE REPLACE(UPPER(`plate`), " ", "") = ? LIMIT 1'):format(column, tableName),
        { key }
    )
    if not rows[1] or not rows[1][column] then return end
    local props = patchColor(decodeProps(rows[1][column]), color)
    if not props then return end
    dbExec(
        ('UPDATE `%s` SET `%s` = ? WHERE REPLACE(UPPER(`plate`), " ", "") = ?'):format(tableName, column),
        { json.encode(props), key }
    )
end

function SaveChameleonPaint(plate, color)
    color = tonumber(color)
    if not color then return end
    local key = PlateKey(plate)
    if key == '' then return end

    cache[key] = color
    SetResourceKvp(kvpKey(plate), tostring(color))

    dbExec(
        'INSERT INTO chameleon_vehicle_paints (plate, plate_key, color) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE plate = VALUES(plate), color = VALUES(color)',
        { TrimPlate(plate), key, color }
    )

    if GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started' then
        updateOwnedVehicleRow('player_vehicles', 'mods', plate, color)
    end
    if GetResourceState('es_extended') == 'started' then
        updateOwnedVehicleRow('owned_vehicles', 'vehicle', plate, color)
    end
end

function PlayerOwnsVehicle(src, plate)
    if not Config.RequireOwnedVehicle then return true end
    local key = PlateKey(plate)
    if key == '' then return false end

    if GetResourceState('qbx_core') == 'started' then
        local player = exports.qbx_core:GetPlayer(src)
        local citizenid = player and player.PlayerData and player.PlayerData.citizenid
        if not citizenid then return false end
        local rows = dbQuery(
            'SELECT 1 FROM player_vehicles WHERE citizenid = ? AND REPLACE(UPPER(plate), " ", "") = ? LIMIT 1',
            { citizenid, key }
        )
        return rows[1] ~= nil
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if not ok or not QBCore then return false end
        local player = QBCore.Functions.GetPlayer(src)
        local citizenid = player and player.PlayerData and player.PlayerData.citizenid
        if not citizenid then return false end
        local rows = dbQuery(
            'SELECT 1 FROM player_vehicles WHERE citizenid = ? AND REPLACE(UPPER(plate), " ", "") = ? LIMIT 1',
            { citizenid, key }
        )
        return rows[1] ~= nil
    end

    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if not ok or not ESX then return false end
        local player = ESX.GetPlayerFromId(src)
        local identifier = player and player.identifier
        if not identifier then return false end
        local rows = dbQuery(
            'SELECT 1 FROM owned_vehicles WHERE owner = ? AND REPLACE(UPPER(plate), " ", "") = ? LIMIT 1',
            { identifier, key }
        )
        return rows[1] ~= nil
    end

    -- No framework: allow paint, persistence still uses KVP + SQL table.
    return true
end

local function loadCache()
    local rows = dbQuery('SELECT plate_key, color FROM chameleon_vehicle_paints', {})
    for i = 1, #rows do
        local row = rows[i]
        local key = row.plate_key and tostring(row.plate_key):upper() or nil
        local color = tonumber(row.color)
        if key and color then
            cache[key] = color
            SetResourceKvp('paint:' .. key, tostring(color))
        end
    end
    tableReady = true
    print(('[djfivem-spraypaint] loaded %s saved chameleon paints'):format(#rows))
end

CreateThread(function()
    if sqlAvailable() then
        dbExec([[
            CREATE TABLE IF NOT EXISTS `chameleon_vehicle_paints` (
                `plate` VARCHAR(16) NOT NULL,
                `plate_key` VARCHAR(16) NOT NULL,
                `color` INT NOT NULL,
                `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`plate_key`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]], {})
        Wait(500)
        loadCache()
    else
        tableReady = true
        print('[djfivem-spraypaint] oxmysql not started — paints still persist via resource KVP until SQL is available.')
    end
end)

AddEventHandler('entityCreated', function(entity)
    if not entity then return end
    CreateThread(function()
        Wait(250)
        if not DoesEntityExist(entity) then return end
        if GetEntityType(entity) ~= 2 then return end
        local plate = GetVehicleNumberPlateText(entity)
        local color = GetSavedColor(plate)
        if color then
            Entity(entity).state:set('chameleonPaint', color, true)
        end
    end)
end)
