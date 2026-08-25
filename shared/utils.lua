function TrimPlate(plate)
    if plate == nil then return '' end
    plate = tostring(plate)
    plate = plate:gsub('^%s+', ''):gsub('%s+$', '')
    return plate
end

function PlateKey(plate)
    local trimmed = TrimPlate(plate)
    trimmed = trimmed:gsub('%s+', '')
    return trimmed:upper()
end

function DisplayItemLabel(paint)
    if not paint then return 'Chameleon Spray' end
    return ('#%s %s'):format(paint.number, paint.label)
end
