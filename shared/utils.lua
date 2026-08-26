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

-- GTA heading 0 = north (+Y). Returns the 2D forward-vector dot product toward a point.
function HeadingDotToTarget(heading, fromX, fromY, toX, toY)
    local rad = math.rad(tonumber(heading) or 0)
    local fx = -math.sin(rad)
    local fy = math.cos(rad)
    local dx = (tonumber(toX) or 0) - (tonumber(fromX) or 0)
    local dy = (tonumber(toY) or 0) - (tonumber(fromY) or 0)
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len < 0.001 then
        return 1.0
    end
    dx = dx / len
    dy = dy / len
    return (fx * dx) + (fy * dy)
end

function IsFacingTarget(heading, fromX, fromY, toX, toY, maxAngle)
    local angle = tonumber(maxAngle) or 70
    local dot = HeadingDotToTarget(heading, fromX, fromY, toX, toY)
    return dot >= math.cos(math.rad(angle))
end
