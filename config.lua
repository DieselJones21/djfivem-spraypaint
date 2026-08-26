Config = {}

-- Colour indexes match GTA (161-242) on gamebuild 2699+.
-- 161-222 = 62 official Rockstar chameleon paints
-- 223-242 = 20 custom YKTA paints from the GTA5-Mods pack

-- Stand outside, face the vehicle, then use the spray (spray-can prop is attached).
Config.AllowOutsideVehicle = true
Config.OutsideMaxDistance = 5.0
Config.RequireFacingVehicle = true
Config.FacingMaxAngle = 70

-- Also allow spraying from the driver seat.
Config.AllowInsideVehicle = true
Config.RequireDriver = true

-- Paint both primary and secondary the same chameleon colour.
Config.PaintSecondary = true

-- Remove the spray can item only after a successful paint (not if they cancel).
Config.ConsumeOnSuccess = true

-- Donation paint-remover tool. Face a vehicle and use it to strip chameleon paint.
Config.RemoverItem = 'dono_paint_remover'
-- false = reusable donor tool. Set true to consume one per use.
Config.RemoverConsume = false
-- Colour applied after removal (0 = metallic black).
Config.RemoverDefaultPrimary = 0
Config.RemoverDefaultSecondary = 0

-- Seconds-style durations (ms).
Config.ShakeDuration = 3500
Config.PaintDuration = 4500
Config.InsideDuration = 4000
Config.RemoverDuration = 4500

-- Keep re-applying so garage scripts / SetVehicleProperties cannot wipe the colour.
Config.KeepApplying = true
Config.KeepApplyingInterval = 2000

-- Optional: only owned vehicles can be painted / stripped.
Config.RequireOwnedVehicle = false

Config.Notify = {
    notInVehicle = 'Stand outside a vehicle and face it, or sit in the driver seat, to use this.',
    notDriver = 'You must be in the driver seat to spray from inside.',
    tooFar = 'Get closer to a vehicle to spray it.',
    notFacing = 'Face the vehicle, then use the spray.',
    cancelled = 'You stopped spraying.',
    success = 'Chameleon paint applied.',
    removed = 'Chameleon paint removed.',
    noPaint = 'This vehicle has no chameleon paint to remove.',
    noItem = 'You do not have that item.',
    busy = 'You are already spraying.',
    invalid = 'That spray cannot be used.',
    notOwned = 'You can only paint vehicles you own.',
}

Config.Progress = {
    shake = 'Shaking spray can',
    painting = 'Spraying chameleon paint',
    inside = 'Spraying chameleon paint',
    removing = 'Removing chameleon paint',
}

-- ACE or framework group names that can use /givechameleon and /giveremover
Config.AdminGroups = {
    'god',
    'admin',
    'superadmin',
    'group.admin',
}

Config.Debug = false
