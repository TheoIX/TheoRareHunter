local addonName, ns = ...

local frame = CreateFrame("Frame")
local scanner = CreateFrame("Frame")
local scanUnits = { "target", "mouseover", "focus" }

for i = 1, 40 do
    scanUnits[#scanUnits + 1] = "nameplate" .. i
end

local function CopyDefaults(src, dst)
    if type(dst) ~= "table" then dst = {} end
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99TheoRareHunter:|r " .. tostring(msg))
end

ns.Print = Print

local function GetPlayerMapPoint()
    if not C_Map or not C_Map.GetBestMapForUnit or not C_Map.GetPlayerMapPosition then
        return nil, nil, nil
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil, nil, nil end
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return mapID, nil, nil end
    local x, y = pos:GetXY()
    if not x or not y then return mapID, nil, nil end
    return mapID, x * 100, y * 100
end

ns.GetPlayerMapPoint = GetPlayerMapPoint

function ns.GetNPCIDFromGUID(guid)
    if not guid then return nil end
    local unitType, zero, serverID, instanceID, zoneUID, id = strsplit("-", guid)
    if unitType == "Creature" or unitType == "Vehicle" then
        return tonumber(id)
    end
    return nil
end

local function GetUnitRare(unit)
    if not UnitExists(unit) then return nil end
    local guid = UnitGUID(unit)
    local npcID = ns.GetNPCIDFromGUID(guid)
    if npcID and ns.RARES_BY_NPCID[npcID] then
        return ns.RARES_BY_NPCID[npcID], npcID
    end

    -- Name fallback helps on odd/private builds where GUID parsing differs.
    local name = UnitName(unit)
    if name then
        return ns.RARES_BY_NAME[string.lower(name)]
    end
    return nil
end

local function PlayFoundSound()
    if not TheoRareHunterSaved.sound then return end

    -- SOUNDKIT may vary across clients/private builds, so try several safe fallbacks.
    if SOUNDKIT and SOUNDKIT.RAID_WARNING then
        PlaySound(SOUNDKIT.RAID_WARNING, "Master")
    elseif SOUNDKIT and SOUNDKIT.ALARM_CLOCK_WARNING_3 then
        PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "Master")
    else
        PlaySound(8959, "Master")
    end
end

local function AlertRare(unit, rare, npcID)
    if not TheoRareHunterSaved.alert then return end
    npcID = npcID or rare.npcID
    local now = GetTime()
    local last = TheoRareHunterSaved.lastSeen[npcID] or 0
    local cooldown = TheoRareHunterSaved.alertCooldown or 300
    if now - last < cooldown then return end

    TheoRareHunterSaved.lastSeen[npcID] = now

    local mapID, x, y = GetPlayerMapPoint()
    TheoRareHunterSaved.found[npcID] = {
        name = rare.name,
        time = time(),
        zone = GetZoneText() or ns.MAP_NAMES[rare.mapID] or "Unknown",
        mapID = mapID or rare.mapID,
        x = x,
        y = y,
    }

    local loc = ""
    if x and y then
        loc = string.format(" near %.1f, %.1f", x, y)
    end

    local msg = "RARE FOUND: " .. rare.name .. loc .. "!"

    if TheoRareHunterSaved.chat then
        Print("|cffff2020" .. msg .. "|r")
    end

    if TheoRareHunterSaved.raidWarning and RaidNotice_AddMessage and RaidWarningFrame then
        RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
    end

    PlayFoundSound()
end

function ns.ScanUnit(unit)
    if not TheoRareHunterSaved or not TheoRareHunterSaved.enabled then return end
    local rare, npcID = GetUnitRare(unit)
    if rare then
        AlertRare(unit, rare, npcID)
        return true
    end
    return false
end

function ns.ScanAllUnits()
    if not TheoRareHunterSaved or not TheoRareHunterSaved.enabled then return end
    for _, unit in ipairs(scanUnits) do
        ns.ScanUnit(unit)
    end
end

local elapsed = 0
scanner:SetScript("OnUpdate", function(_, delta)
    if not TheoRareHunterSaved or not TheoRareHunterSaved.enabled then return end
    elapsed = elapsed + delta
    local throttle = TheoRareHunterSaved.scanThrottle or 0.75
    if elapsed >= throttle then
        elapsed = 0
        ns.ScanAllUnits()
    end
end)

local function RefreshPins()
    if ns.RefreshMapPins then
        ns.RefreshMapPins()
    end
end

ns.NotifyHandyNotes = RefreshPins -- legacy name kept so older code paths still refresh pins

local function BoolText(value)
    if value then return "ON" end
    return "OFF"
end

local function PrintStatus()
    Print("enabled: " .. BoolText(TheoRareHunterSaved.enabled)
        .. ", alerts: " .. BoolText(TheoRareHunterSaved.alert)
        .. ", sound: " .. BoolText(TheoRareHunterSaved.sound)
        .. ", map pins: " .. BoolText(TheoRareHunterSaved.showMapPins)
        .. ", minimap pins: " .. BoolText(TheoRareHunterSaved.showMinimapPins)
        .. string.format(", scale: %.2f, alpha: %.2f, minimap range: %.1f", TheoRareHunterSaved.iconScale or 0.90, TheoRareHunterSaved.iconAlpha or 0.95, TheoRareHunterSaved.minimapRange or 8))
end

local function PrintFound()
    local count = 0
    for npcID, info in pairs(TheoRareHunterSaved.found or {}) do
        count = count + 1
        local when = info.time and date("%Y-%m-%d %H:%M:%S", info.time) or "unknown time"
        local loc = ""
        if info.x and info.y then
            loc = string.format(" %.1f, %.1f", info.x, info.y)
        end
        Print(string.format("%s [%d] - %s%s - %s", info.name or "Unknown", npcID, info.zone or "Unknown", loc, when))
    end
    if count == 0 then
        Print("No rares recorded yet.")
    end
end

local function FindRareByText(text)
    if not text or text == "" then return nil end
    local id = tonumber(text)
    if id and ns.RARES_BY_NPCID[id] then return ns.RARES_BY_NPCID[id] end
    text = string.lower(text)
    for name, rare in pairs(ns.RARES_BY_NAME) do
        if string.find(name, text, 1, true) then
            return rare
        end
    end
    return nil
end

local function SlashHandler(msg)
    msg = msg or ""
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = string.lower(cmd or "")

    if cmd == "on" then
        TheoRareHunterSaved.enabled = true
        Print("scanner ON")
    elseif cmd == "off" then
        TheoRareHunterSaved.enabled = false
        Print("scanner OFF")
    elseif cmd == "alert" or cmd == "alerts" then
        TheoRareHunterSaved.alert = not TheoRareHunterSaved.alert
        Print("alerts " .. BoolText(TheoRareHunterSaved.alert))
    elseif cmd == "sound" then
        TheoRareHunterSaved.sound = not TheoRareHunterSaved.sound
        Print("sound " .. BoolText(TheoRareHunterSaved.sound))
    elseif cmd == "rw" or cmd == "raidwarning" then
        TheoRareHunterSaved.raidWarning = not TheoRareHunterSaved.raidWarning
        Print("raid warning " .. BoolText(TheoRareHunterSaved.raidWarning))
    elseif cmd == "pins" or cmd == "pin" then
        TheoRareHunterSaved.showPins = not TheoRareHunterSaved.showPins
        TheoRareHunterSaved.showMapPins = TheoRareHunterSaved.showPins
        TheoRareHunterSaved.showMinimapPins = TheoRareHunterSaved.showPins
        Print("all pins " .. BoolText(TheoRareHunterSaved.showPins))
        RefreshPins()
    elseif cmd == "map" or cmd == "mappins" then
        TheoRareHunterSaved.showMapPins = not TheoRareHunterSaved.showMapPins
        if TheoRareHunterSaved.showMapPins or TheoRareHunterSaved.showMinimapPins then TheoRareHunterSaved.showPins = true end
        Print("world map pins " .. BoolText(TheoRareHunterSaved.showMapPins))
        RefreshPins()
    elseif cmd == "minimap" or cmd == "minipins" then
        TheoRareHunterSaved.showMinimapPins = not TheoRareHunterSaved.showMinimapPins
        if TheoRareHunterSaved.showMapPins or TheoRareHunterSaved.showMinimapPins then TheoRareHunterSaved.showPins = true end
        Print("minimap pins " .. BoolText(TheoRareHunterSaved.showMinimapPins))
        RefreshPins()
    elseif cmd == "range" or cmd == "minimaprange" then
        local value = tonumber(rest)
        if value and value >= 2 and value <= 25 then
            TheoRareHunterSaved.minimapRange = value
            RefreshPins()
            Print(string.format("minimap range set to %.1f map-percent", value))
        else
            Print("usage: /trh range 8   (range 2 to 25)")
        end
    elseif cmd == "refresh" then
        RefreshPins()
        Print("refreshed TheoRareHunter standalone pins")
    elseif cmd == "scale" then
        local value = tonumber(rest)
        if value and value >= 0.5 and value <= 3.0 then
            TheoRareHunterSaved.iconScale = value
            RefreshPins()
            Print(string.format("icon scale set to %.2f", value))
        else
            Print("usage: /trh scale 0.9   (range 0.5 to 3.0)")
        end
    elseif cmd == "alpha" then
        local value = tonumber(rest)
        if value and value >= 0.1 and value <= 1.0 then
            TheoRareHunterSaved.iconAlpha = value
            RefreshPins()
            Print(string.format("icon alpha set to %.2f", value))
        else
            Print("usage: /trh alpha 0.95   (range 0.1 to 1.0)")
        end
    elseif cmd == "found" then
        PrintFound()
    elseif cmd == "resetfound" then
        TheoRareHunterSaved.found = {}
        Print("found list cleared")
    elseif cmd == "scan" then
        ns.ScanAllUnits()
        Print("manual scan complete")
    elseif cmd == "where" then
        local mapID, x, y = GetPlayerMapPoint()
        if mapID and x and y then
            Print(string.format("mapID %d (%s) at %.1f, %.1f", mapID, ns.MAP_NAMES[mapID] or GetZoneText() or "unknown", x, y))
        elseif mapID then
            Print(string.format("mapID %d (%s); no player coords yet", mapID, ns.MAP_NAMES[mapID] or GetZoneText() or "unknown"))
        else
            Print("Could not read current map. Try after zoning or opening the map once.")
        end
    elseif cmd == "test" then
        local rare = FindRareByText(rest)
        if rare then
            TheoRareHunterSaved.lastSeen[rare.npcID] = nil
            AlertRare("player", rare, rare.npcID)
        else
            Print("usage: /trh test 18677  or  /trh test mekthorg")
        end
    else
        PrintStatus()
        Print("commands: /trh on, off, alert, sound, rw, pins, map, minimap, range <n>, refresh, scale <n>, alpha <n>, found, resetfound, scan, where, test <npcID/name>")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
frame:RegisterEvent("ZONE_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        TheoRareHunterSaved = CopyDefaults(ns.DEFAULTS, TheoRareHunterSaved)
    elseif event == "PLAYER_LOGIN" then
        TheoRareHunterSaved = CopyDefaults(ns.DEFAULTS, TheoRareHunterSaved)
        SLASH_THEORAREHUNTER1 = "/trh"
        SLASH_THEORAREHUNTER2 = "/theorarehunter"
        SlashCmdList["THEORAREHUNTER"] = SlashHandler
        Print("loaded v" .. ns.VERSION .. ". Type /trh for options.")
        RefreshPins()
    elseif event == "PLAYER_TARGET_CHANGED" then
        ns.ScanUnit("target")
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        ns.ScanUnit("mouseover")
    elseif event == "PLAYER_FOCUS_CHANGED" then
        ns.ScanUnit("focus")
    elseif event == "NAME_PLATE_UNIT_ADDED" and arg1 then
        ns.ScanUnit(arg1)
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
        ns.ScanAllUnits()
    end
end)
