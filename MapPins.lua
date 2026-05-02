local addonName, ns = ...

-- Standalone world map + minimap pins.
-- This intentionally does NOT load or talk to HandyNotes or Questie.

local worldPins = {}
local minimapPins = {}
local mapFrame = CreateFrame("Frame")
local updateElapsed = 0

local function SafeSaved()
    return TheoRareHunterSaved or ns.DEFAULTS or {}
end

local function GetDisplayedMapID()
    if WorldMapFrame then
        if WorldMapFrame.GetMapID then
            local id = WorldMapFrame:GetMapID()
            if id then return id end
        end
        if WorldMapFrame.mapID then return WorldMapFrame.mapID end
    end
    if C_Map and C_Map.GetBestMapForUnit then
        return C_Map.GetBestMapForUnit("player")
    end
    return nil
end

local function GetWorldMapPinParent()
    if not WorldMapFrame then return nil end

    if WorldMapFrame.ScrollContainer then
        if WorldMapFrame.ScrollContainer.Child then
            return WorldMapFrame.ScrollContainer.Child
        elseif WorldMapFrame.ScrollContainer.GetScrollChild then
            local child = WorldMapFrame.ScrollContainer:GetScrollChild()
            if child then return child end
        end
    end

    if WorldMapDetailFrame then return WorldMapDetailFrame end
    return WorldMapFrame
end

local function GetPlayerMapPoint()
    if ns.GetPlayerMapPoint then
        return ns.GetPlayerMapPoint()
    end
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

local function Pin_OnEnter(self)
    local data = self.data
    if not data or not data.rare then return end
    local rare = data.rare

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(rare.name or "Rare Spawn", 1, 0.82, 0)
    GameTooltip:AddLine((rare.classification or "Rare") .. "  |  NPC ID: " .. tostring(rare.npcID), 1, 1, 1)
    GameTooltip:AddLine((ns.MAP_NAMES[rare.mapID] or "Unknown") .. string.format(" %.1f, %.1f", data.x or 0, data.y or 0), 0.8, 0.8, 0.8)
    if rare.note then
        GameTooltip:AddLine(rare.note, 0.6, 0.9, 1, true)
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("TheoRareHunter scans target, mouseover, focus, and nameplates for this NPC ID.", 0.75, 0.75, 0.75, true)
    GameTooltip:Show()
end

local function Pin_OnLeave()
    GameTooltip:Hide()
end

local function Pin_OnClick(self, button)
    if button ~= "RightButton" then return end
    local data = self.data
    if not data or not data.rare then return end
    local rare = data.rare
    if IsShiftKeyDown() then
        print(string.format("/way %s %.1f %.1f %s", ns.MAP_NAMES[rare.mapID] or tostring(rare.mapID), data.x or 0, data.y or 0, rare.name or "Rare"))
    else
        print(string.format("TheoRareHunter: %s [%s] at %.1f, %.1f", rare.name or "Rare", tostring(rare.npcID), data.x or 0, data.y or 0))
    end
end

local function StylePin(pin)
    pin:SetFrameStrata("HIGH")
    pin:SetFrameLevel(9000)
    pin:EnableMouse(true)
    pin:RegisterForClicks("RightButtonUp")

    if not pin.tex then
        pin.tex = pin:CreateTexture(nil, "OVERLAY")
        pin.tex:SetAllPoints(pin)
    end

    pin.tex:SetTexture(ns.ICON_RARE or "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8")
    pin.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    pin:SetScript("OnEnter", Pin_OnEnter)
    pin:SetScript("OnLeave", Pin_OnLeave)
    pin:SetScript("OnClick", Pin_OnClick)
end

local function AcquireWorldPin(parent, index)
    local pin = worldPins[index]
    if not pin then
        pin = CreateFrame("Button", nil, parent)
        StylePin(pin)
        worldPins[index] = pin
    elseif pin:GetParent() ~= parent then
        pin:SetParent(parent)
    end
    return pin
end

local function AcquireMinimapPin(index)
    local pin = minimapPins[index]
    if not pin then
        pin = CreateFrame("Button", nil, Minimap)
        StylePin(pin)
        minimapPins[index] = pin
    end
    return pin
end

local function HidePins(pinTable)
    for _, pin in ipairs(pinTable) do
        pin:Hide()
    end
end

local function RefreshWorldMapPins()
    HidePins(worldPins)

    local saved = SafeSaved()
    if not saved.showPins or not saved.showMapPins then return end
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end

    local parent = GetWorldMapPinParent()
    if not parent then return end

    local mapID = GetDisplayedMapID()
    if not mapID then return end

    local width = parent:GetWidth()
    local height = parent:GetHeight()
    if not width or width <= 1 or not height or height <= 1 then return end

    local size = 22 * (saved.iconScale or 0.90)
    local alpha = saved.iconAlpha or 0.95
    local count = 0

    for _, rare in ipairs(ns.RARES or {}) do
        if rare.mapID == mapID and rare.points then
            for _, point in ipairs(rare.points) do
                count = count + 1
                local pin = AcquireWorldPin(parent, count)
                pin.data = { rare = rare, x = point[1], y = point[2] }
                pin:SetSize(size, size)
                pin:SetAlpha(alpha)
                pin:ClearAllPoints()
                pin:SetPoint("CENTER", parent, "TOPLEFT", (point[1] / 100) * width, -(point[2] / 100) * height)
                pin:Show()
            end
        end
    end
end

local function RefreshMinimapPins()
    HidePins(minimapPins)

    local saved = SafeSaved()
    if not saved.showPins or not saved.showMinimapPins then return end
    if not Minimap or not Minimap:IsShown() then return end

    local mapID, playerX, playerY = GetPlayerMapPoint()
    if not mapID or not playerX or not playerY then return end

    local range = saved.minimapRange or 8
    if range <= 0 then range = 8 end

    local radius = (Minimap:GetWidth() or 140) * 0.42
    local size = 11 * (saved.iconScale or 0.50)
    local alpha = saved.iconAlpha or 0.95
    local count = 0

    for _, rare in ipairs(ns.RARES or {}) do
        if rare.mapID == mapID and rare.points then
            for _, point in ipairs(rare.points) do
                local dx = point[1] - playerX
                local dy = point[2] - playerY
                local dist = math.sqrt(dx * dx + dy * dy)
                if dist <= range then
                    count = count + 1
                    local pin = AcquireMinimapPin(count)
                    pin.data = { rare = rare, x = point[1], y = point[2] }
                    pin:SetSize(size, size)
                    pin:SetAlpha(alpha)
                    pin:ClearAllPoints()
                    pin:SetPoint("CENTER", Minimap, "CENTER", (dx / range) * radius, -(dy / range) * radius)
                    pin:Show()
                end
            end
        end
    end
end

function ns.RefreshMapPins()
    RefreshWorldMapPins()
    RefreshMinimapPins()
end

mapFrame:RegisterEvent("PLAYER_LOGIN")
mapFrame:RegisterEvent("ZONE_CHANGED")
mapFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
mapFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
mapFrame:SetScript("OnEvent", function()
    if ns.RefreshMapPins then ns.RefreshMapPins() end
end)

mapFrame:SetScript("OnUpdate", function(_, elapsed)
    updateElapsed = updateElapsed + elapsed
    if updateElapsed >= 0.50 then
        updateElapsed = 0
        if ns.RefreshMapPins then ns.RefreshMapPins() end
    end
end)

if WorldMapFrame then
    WorldMapFrame:HookScript("OnShow", function()
        if ns.RefreshMapPins then ns.RefreshMapPins() end
    end)
    WorldMapFrame:HookScript("OnHide", function()
        HidePins(worldPins)
    end)
end
