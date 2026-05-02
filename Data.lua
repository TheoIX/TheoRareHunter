local addonName, ns = ...

ns.VERSION = "0.2.0"

-- TBC Classic 2.5.x C_Map UiMapIDs. Confirm in-game with: /dump C_Map.GetBestMapForUnit("player")
ns.MAP_NAMES = {
    -- TBC Classic 2.5.x UiMapIDs. Verify any zone with: /dump C_Map.GetBestMapForUnit("player")
    [1944] = "Hellfire Peninsula",
    [1946] = "Zangarmarsh",
    [1952] = "Terokkar Forest",
    [1951] = "Nagrand",
    [1953] = "Netherstorm",
    [1948] = "Shadowmoon Valley",
    [1949] = "Blade's Edge Mountains",
}

ns.DEFAULTS = {
    enabled = true,
    showPins = true,
    showMapPins = true,
    showMinimapPins = true,
    minimapRange = 8,
    alert = true,
    sound = true,
    raidWarning = true,
    chat = true,
    scanThrottle = 0.75,
    alertCooldown = 300,
    iconScale = 0.90,
    iconAlpha = 0.95,
    found = {},
    lastSeen = {},
}

ns.ICON_RARE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"

-- Coordinates are starter spawn/patrol points for Outland rare hunting.
-- Add or tune points freely; the scanner uses NPC IDs, so alerts remain accurate even if a pin is rough.
ns.RARES = {
    -- Hellfire Peninsula
    {
        npcID = 18677,
        name = "Mekthorg the Wild",
        mapID = 1944,
        classification = "Rare",
        note = "Fel orc rare. Spawn/patrol areas around Hellfire Citadel and Zeth'Gor.",
        points = {
            {46.0, 42.8}, {49.1, 53.3}, {54.0, 50.8}, {66.6, 76.8},
        },
    },
    {
        npcID = 18678,
        name = "Fulgorge",
        mapID = 1944,
        classification = "Rare Elite",
        note = "Burrowing worm. Watch for very large red/brown rumbling rocks; target/nameplate scans may only catch him briefly.",
        points = {
            {25.0, 47.0}, {31.0, 63.0}, {41.0, 71.0}, {45.0, 50.0}, {50.3, 70.8},
        },
    },
    {
        npcID = 18679,
        name = "Vorakem Doomspeaker",
        mapID = 1944,
        classification = "Rare",
        note = "Demon rare. Reported around Pools of Aggonar, Legion Front, and forge/invasion points.",
        points = {
            {42.6, 31.3}, {58.0, 32.0}, {64.0, 31.0}, {68.0, 48.0}, {71.0, 53.0},
        },
    },

    -- Zangarmarsh
    {
        npcID = 18682,
        name = "Bog Lurker",
        mapID = 1946,
        classification = "Rare",
        note = "Bog giant. Patrols near Umbrafen, Feralfen, and Daggerfen broken villages.",
        points = {
            {24.4, 20.6}, {26.0, 20.2}, {27.0, 20.6}, {28.0, 23.2}, {26.8, 26.2}, {25.6, 29.4},
            {40.4, 65.6}, {43.2, 59.0}, {45.0, 48.8}, {48.6, 58.4}, {51.2, 61.1}, {50.0, 66.8},
            {82.8, 78.6}, {84.4, 79.2}, {86.2, 82.8}, {86.0, 85.2}, {86.4, 89.0},
        },
    },
    {
        npcID = 18681,
        name = "Coilfang Emissary",
        mapID = 1946,
        classification = "Rare",
        note = "Naga rare. Usually around steam pump / naga areas.",
        points = {
            {50.0, 40.0}, {64.8, 41.0}, {70.0, 34.0}, {72.0, 57.0}, {75.0, 76.0},
        },
    },
    {
        npcID = 18680,
        name = "Marticar",
        mapID = 1946,
        classification = "Rare Elite",
        note = "White strider. Patrols around several large lakes and marsh paths.",
        points = {
            {18.5, 38.0}, {24.0, 33.0}, {32.0, 49.0}, {43.0, 52.0}, {55.0, 42.0}, {68.0, 67.0}, {78.0, 76.0},
        },
    },

    -- Terokkar Forest
    {
        npcID = 18689,
        name = "Crippler",
        mapID = 1952,
        classification = "Rare",
        note = "Bone golem. Mostly The Bone Wastes / Auchindoun area.",
        points = {
            {35.0, 65.0}, {40.0, 75.0}, {47.0, 72.0}, {51.0, 63.0}, {57.0, 58.0}, {48.0, 52.0}, {38.0, 48.0},
        },
    },
    {
        npcID = 18686,
        name = "Doomsayer Jurim",
        mapID = 1952,
        classification = "Rare",
        note = "Draenei warlock. Patrols roads east/south of Shattrath, Tuurem, Cenarion Thicket, and Firewing Point.",
        points = {
            {47.5, 27.1}, {55.0, 25.0}, {62.0, 34.0}, {65.0, 50.0}, {57.0, 54.0}, {49.0, 50.0},
        },
    },
    {
        npcID = 18685,
        name = "Okrek",
        mapID = 1952,
        classification = "Rare",
        note = "Arakkoa rare. Check Veil Reskk, Shienor, Skith, and Shalas camps.",
        points = {
            {32.0, 42.0}, {37.0, 48.0}, {49.0, 18.0}, {53.9, 70.9}, {56.2, 69.4}, {56.0, 68.0},
        },
    },

    -- Nagrand
    {
        npcID = 18684,
        name = "Bro'Gaz the Clanless",
        mapID = 1951,
        classification = "Rare",
        note = "Ogre rare. Roams several areas of Nagrand.",
        points = {
            {32.3, 25.6}, {40.0, 35.0}, {52.7, 51.9}, {61.0, 67.0}, {70.0, 42.0},
        },
    },
    {
        npcID = 17144,
        name = "Goretooth",
        mapID = 1951,
        classification = "Rare",
        note = "Crocolisk. Check water areas; may be underwater.",
        points = {
            {35.6, 50.4}, {43.0, 45.0}, {59.3, 32.9}, {61.0, 41.0}, {42.0, 82.0},
        },
    },
    {
        npcID = 18683,
        name = "Voidhunter Yar",
        mapID = 1951,
        classification = "Rare",
        note = "Voidlord rare around Oshu'gun / southwestern Nagrand.",
        points = {
            {27.0, 69.0}, {31.0, 55.0}, {35.0, 66.0}, {41.0, 74.0}, {44.0, 63.0},
        },
    },

    -- Netherstorm
    {
        npcID = 18697,
        name = "Chief Engineer Lorthander",
        mapID = 1953,
        classification = "Rare",
        note = "Blood elf rare. Check Manaforge areas; he can be inside/near manaforges.",
        points = {
            {26.0, 67.0}, {31.0, 40.0}, {47.0, 82.0}, {59.0, 63.0}, {60.0, 39.0},
        },
    },
    {
        npcID = 18698,
        name = "Ever-Core the Punisher",
        mapID = 1953,
        classification = "Rare",
        note = "Arcane golem rare. Circles manaforge areas.",
        points = {
            {23.0, 67.0}, {28.0, 37.0}, {35.0, 76.0}, {58.0, 74.0}, {60.0, 39.0},
        },
    },
    {
        npcID = 20932,
        name = "Nuramoc",
        mapID = 1953,
        classification = "Rare Elite / Tameable",
        note = "Purple chimaera. Roams long lines through Netherstorm; tameable by hunters.",
        points = {
            {25.0, 66.0}, {35.0, 59.0}, {36.0, 35.0}, {45.0, 58.0}, {48.0, 42.0}, {54.0, 67.0}, {60.0, 48.0},
        },
    },

    -- Shadowmoon Valley
    {
        npcID = 18695,
        name = "Ambassador Jerrikar",
        mapID = 1948,
        classification = "Rare",
        note = "Red satyr. Patrols Coilskar Point, Ruins of Baa'ri, Dragonmaw Fortress, Eclipse Point, and Illidari Point.",
        points = {
            {29.0, 50.0}, {45.0, 25.0}, {48.0, 67.0}, {61.0, 37.0}, {67.0, 59.0},
        },
    },
    {
        npcID = 18694,
        name = "Collidus the Warp-Watcher",
        mapID = 1948,
        classification = "Rare Elite",
        note = "Floating eye demon. Patrols multiple Shadowmoon areas.",
        points = {
            {40.0, 39.0}, {44.0, 32.0}, {54.0, 24.0}, {54.0, 70.0}, {62.0, 48.0}, {68.0, 85.0},
        },
    },
    {
        npcID = 18696,
        name = "Kraator",
        mapID = 1948,
        classification = "Rare Elite",
        note = "Huge abyssal/infernal. Large and easy to spot; can spawn in several Shadowmoon areas.",
        points = {
            {31.0, 44.0}, {41.0, 39.0}, {42.1, 69.0}, {45.5, 12.3}, {59.0, 45.0}, {59.0, 47.0},
        },
    },

    -- Blade's Edge Mountains
    {
        npcID = 18692,
        name = "Hemathion",
        mapID = 1949,
        classification = "Rare Elite / Tameable",
        note = "Dragon. Flying-mount-accessible Ogri'la/Vortex Summit plateau.",
        points = {
            {27.5, 60.0}, {28.5, 65.0}, {31.0, 68.0}, {33.0, 61.0},
        },
    },
    {
        npcID = 18690,
        name = "Morcrush",
        mapID = 1949,
        classification = "Rare Elite",
        note = "Stone giant. Often in eastern/northeastern Blade's Edge and roads toward Netherstorm.",
        points = {
            {60.0, 49.0}, {62.0, 33.0}, {66.0, 16.0}, {70.0, 41.0}, {72.0, 22.0},
        },
    },
    {
        npcID = 18693,
        name = "Speaker Mar'grom",
        mapID = 1949,
        classification = "Rare",
        note = "Ogre rare. Check ogre camps and paths around Bloodmaul/Bladespire/Gruul areas.",
        points = {
            {40.2, 55.5}, {41.4, 49.0}, {45.6, 76.1}, {57.0, 27.2}, {57.1, 32.5},
        },
    },
}

ns.RARES_BY_NPCID = {}
ns.RARES_BY_NAME = {}
ns.RARES_BY_MAP = {}

for _, rare in ipairs(ns.RARES) do
    ns.RARES_BY_NPCID[rare.npcID] = rare
    ns.RARES_BY_NAME[string.lower(rare.name)] = rare
    if not ns.RARES_BY_MAP[rare.mapID] then
        ns.RARES_BY_MAP[rare.mapID] = {}
    end
    table.insert(ns.RARES_BY_MAP[rare.mapID], rare)
end
