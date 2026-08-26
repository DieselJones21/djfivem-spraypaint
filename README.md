# djfivem-spraypaint

Numbered chameleon spray-paint items for FiveM. Stand **outside a vehicle, face it, and use the spray** — a spray-can prop is attached. The colour is saved so it does not disappear after a garage pull-out or server restart.

Includes **all 82 colours** from the [GTA5-Mods Chameleon Paint](https://www.gta5-mods.com/misc/chameleon-paint-add-on) pack (62 official Rockstar + 20 custom YKTA), with spray-can animation from [Testaross/chameleonpaint](https://github.com/Testaross/chameleonpaint).

## What you get

- **82 numbered items:** `chameleonpaint_161` through `chameleonpaint_242` (the number is the GTA colour)
- Use the item **outside**, facing the vehicle (spray-can prop + shake/spray anim). Driver-seat use still works.
- **Donation paint remover** item `dono_paint_remover` — same face-and-spray flow, strips chameleon paint and saves that
- Paint is stored by plate (SQL + resource KVP + your garage `mods` / `vehicle` JSON)
- Colour is re-applied when the vehicle spawns so garage scripts cannot wipe it
- ox_inventory (primary), qb-core, and ESX item support

Full name list: [`install/PAINTS.md`](install/PAINTS.md)

| Range | Pack | Examples |
| --- | --- | --- |
| 161–170 | Official anodized | `#161 Anodized Red Pearl` |
| 171–195 | Official flips | `#180 Blue/Pink Flip` |
| 196–210 | Official pearls | `#200 Oil Slick Pearl` |
| 211–222 | Prismatic / holo | `#221 Black Holographic Pearl` |
| 223–242 | Custom YKTA | `#223 Monochrome`, `#227 Vice City`, `#242 Fubuki Castle` |

If you already added the old 16 items: **numbers now match GTA**. Monochrome is `chameleonpaint_223`, not `161`. Re-paste `install/ox_inventory_items.lua`.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- Game build **2699 or newer** (`sv_enforceGameBuild 2699` in `server.cfg`)
- **ox_inventory** (recommended) or qb-inventory / ESX items
- **oxmysql** (recommended) so paints persist in the database

## Install

1. Copy this folder to `resources/[standalone]/djfivem-spraypaint`  
   **Keep the folder name `djfivem-spraypaint`** (ox_inventory exports use that name).
2. Add to `server.cfg`:

```cfg
ensure ox_lib
ensure oxmysql
ensure ox_inventory
ensure djfivem-spraypaint
```

3. Import `sql/install.sql` into your database (optional — the resource also creates the table on start).
4. Add the items (pick one inventory):

### ox_inventory

Copy every `['chameleonpaint_xxx']` block from `install/ox_inventory_items.lua` into `ox_inventory/data/items.lua`.

Copy `install/ox_inventory_images/*.png` into `ox_inventory/web/images/`. Each spray has its own icon that shows that colour (preview sheet: `install/icon_sheet.png`).

Restart `ox_inventory`.

### qb-core

Copy the item definitions from `install/qb-core_items.lua` into `qb-core/shared/items.lua`.

Copy the PNG files into your inventory images folder (`qb-inventory/html/images/` or `ps-inventory/html/images/`).

### ESX (without ox_inventory)

Run `install/esx_items.sql`.

5. Restart the server (or `ensure djfivem-spraypaint`).

## How to use in-game

1. Give yourself a spray: `/givechameleon 161` (Anodized Red) or `/givechameleon 223` (Monochrome).
2. Get **out** of the vehicle, stand close, and **face** it.
3. Use the item. A spray-can prop is attached; shake, then spray.
4. The car is chameleon-painted and the colour is saved.
5. Store it in the garage and take it out — the paint should still be there.

To strip paint (donation tool): `/giveremover`, face the vehicle, use `dono_paint_remover`. By default the tool is reusable (`Config.RemoverConsume = false`).

`/chameleonpaints` prints every numbered spray to the server console.

## Config

Edit `config.lua`:

- `AllowOutsideVehicle` / `RequireFacingVehicle` / `FacingMaxAngle` — must look at the car to spray it
- `AllowInsideVehicle` — also allow spraying from the driver seat
- `RemoverItem` / `RemoverConsume` / `RemoverDefaultPrimary` — donation paint remover
- `RequireOwnedVehicle = true` — only owned personal vehicles
- `ConsumeOnSuccess` — spray can is removed only if the paint actually applied
- `KeepApplying` — keep restoring the colour so it cannot be wiped

## Why paint used to disappear

The original Testaross script only called `SetVehicleColours` on your client. Garages spawn a new entity and apply saved props, so the chameleon index was lost.

This resource:

1. Saves the colour against the **plate** (`chameleon_vehicle_paints` + KVP)
2. Writes `color1` / `color2` into `player_vehicles.mods` (QB/Qbox) or `owned_vehicles.vehicle` (ESX)
3. Sets a replicated entity state bag
4. Re-applies the colour when the vehicle is created and when you get back in

## Commands

| Command | Who | What |
| --- | --- | --- |
| `/givechameleon [161-242] [id] [count]` | admin | Give a numbered spray |
| `/giveremover [id] [count]` | admin | Give the donation paint remover |
| `/chameleonpaints` | anyone | Print all 82 sprays to the server console |

## Exports

```lua
exports['djfivem-spraypaint']:GetPaints()
exports['djfivem-spraypaint']:GetSavedColor(plate)
exports['djfivem-spraypaint']:ClearChameleonPaint(plate)
```

## Troubleshooting

- **161–222 look black:** set `sv_enforceGameBuild 2699` (or higher) and restart. Those 62 colours are built into that game build.
- **223–242 look black:** confirm `data/` + `stream/vehicle_paint_ramps.ytd` are present and this resource starts before you join.
- **Item does nothing:** items were not added to ox_inventory/qb-core, or you are not facing the vehicle (walk around until you look at it).
- **Remover does nothing:** add `dono_paint_remover` from `install/ox_inventory_items.lua` and copy `dono_paint_remover.png`.
- **Paint vanishes in garage:** import `sql/install.sql`, start `oxmysql` before this resource, and keep `Config.KeepApplying = true`.
- **Sound missing:** this resource plays `html/spraypaint.ogg` itself. You do **not** need to move it to InteractSound.

## License

GNU GPL v3. See `LICENSE` and `COPYRIGHT`.

Based on [Testaross/chameleonpaint](https://github.com/Testaross/chameleonpaint). Custom ramp files also used in [Qbox-project/qbx_customs](https://github.com/Qbox-project/qbx_customs) (GPL-3.0). Credits: Testaross, MrZedo, Wildbrick142, Disquse, Rockstar Games, Qbox.
