Config = {}

-- Colour indexes match GTA (161-242) on gamebuild 2699+.
-- 161-222 = 62 official Rockstar chameleon paints
-- 223-242 = 20 custom YKTA paints from the GTA5-Mods pack

-- Use the spray while sitting in the vehicle (what most servers do).
Config.AllowInsideVehicle = true

-- Also allow spraying a nearby parked car like the original Testaross script.
Config.AllowOutsideVehicle = true
Config.OutsideMaxDistance = 3.0

-- Driver seat only when painting from inside.
Config.RequireDriver = true

-- Paint both primary and secondary the same chameleon colour.
Config.PaintSecondary = true

-- Remove the item only after a successful paint (not if they cancel).
Config.ConsumeOnSuccess = true

-- Seconds-style durations (ms). Original Testaross used 10000 / 10000.
Config.ShakeDuration = 4000
Config.PaintDuration = 5000
Config.InsideDuration = 4000

-- Keep re-applying so garage scripts / SetVehicleProperties cannot wipe the colour.
Config.KeepApplying = true
Config.KeepApplyingInterval = 2000

-- Optional: only owned vehicles can be painted.
Config.RequireOwnedVehicle = false

Config.Notify = {
    notInVehicle = 'You must be in a vehicle, or standing next to one, to use this spray.',
    notDriver = 'You must be in the driver seat to spray this paint.',
    tooFar = 'Get closer to a vehicle to spray it.',
    cancelled = 'You stopped spraying.',
    success = 'Chameleon paint applied.',
    noItem = 'You do not have that spray.',
    busy = 'You are already spraying.',
    invalid = 'That spray cannot be used.',
    notOwned = 'You can only paint vehicles you own.',
}

Config.Progress = {
    shake = 'Shaking can',
    painting = 'Painting',
    inside = 'Spraying chameleon paint',
}

-- ACE or framework group names that can use /givechameleon
Config.AdminGroups = {
    'god',
    'admin',
    'superadmin',
    'group.admin',
}

Config.Debug = false
