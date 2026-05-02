TheoRareHunter v0.2.0 - Standalone

TBC Classic / 2.5.3 rare spawn helper for Outland.

This version does NOT require HandyNotes and does NOT hook into Questie.
It draws its own lightweight pins on the world map and approximate local pins on the minimap.

Install:
1. Delete the old Interface/AddOns/TheoRareHunter folder.
2. Extract this zip into Interface/AddOns/.
3. Make sure the folder is Interface/AddOns/TheoRareHunter/.
4. Disable HandyNotes if it was only being used for TheoRareHunter.
5. Reload the UI.

Commands:
/trh                         Show status and commands
/trh on                      Turn scanner on
/trh off                     Turn scanner off
/trh pins                    Toggle all pins
/trh map                     Toggle world map pins
/trh minimap                 Toggle minimap pins
/trh range 8                 Set minimap local pin radius in map-percent units
/trh scale 0.9               Set icon size
/trh alpha 0.95              Set icon transparency
/trh refresh                 Redraw pins
/trh found                   Show rares detected so far
/trh resetfound              Clear detected list
/trh scan                    Manual scan of target/mouseover/focus/nameplates
/trh where                   Show current C_Map mapID and coords
/trh test 18677              Test alert by NPC ID
/trh test mekthorg           Test alert by partial name

Notes:
- World map pins are exact percentage coordinates for the current zone map.
- Minimap pins are approximate local coordinate projections. They are intended as a nearby spawn hint, not a perfect GPS overlay.
- Detection alerts do not depend on pins. The scanner uses NPC IDs from target, mouseover, focus, and nameplates.
