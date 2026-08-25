# djfivem-spraypaint

Numbered chameleon spray-paint items for FiveM. Sit in a car, use the item, and the colour is saved so it does not disappear after a garage pull-out or server restart.

This resource includes the chameleon ramp files, spray-can animation, and numbered items from [Testaross/chameleonpaint](https://github.com/Testaross/chameleonpaint), plus persistence that the original script did not have.

## What you get

- **16 numbered items:** `chameleonpaint_161` through `chameleonpaint_176`
- Use the item **in a vehicle** (driver seat) or standing next to a car
- Spray-can prop, shake/paint progress bar, and spray sound
- Paint is stored by plate (SQL + resource KVP + your garage `mods` / `vehicle` JSON)
- Colour is re-applied when the vehicle spawns so garage scripts cannot wipe it
- ox_inventory (primary), qb-core, and ESX item support

| Item | Label | Colour index (build 2699+) |
| --- | --- | --- |
| `chameleonpaint_161` | #161 Monochrome Spray | 223 |
| `chameleonpaint_162` | #162 Night & Day Spray | 224 |
| `chameleonpaint_163` | #163 The Verlierer Spray | 225 |
| `chameleonpaint_164` | #164 Sprunk Extreme Spray | 226 |
| `chameleonpaint_165` | #165 Vice City Spray | 227 |
| `chameleonpaint_166` | #166 Synthwave Nights Spray | 228 |
| `chameleonpaint_167` | #167 Four Seasons Spray | 229 |
| `chameleonpaint_168` | #168 Maisonette 9 Throwback Spray | 230 |
| `chameleonpaint_169` | #169 Bubblegum Spray | 231 |
| `chameleonpaint_170` | #170 Full Rainbow Spray | 232 |
| `chameleonpaint_171` | #171 Sunset Spray | 233 |
| `chameleonpaint_172` | #172 The Seven Spray | 234 |
| `chameleonpaint_173` | #173 Kamen Rider Spray | 235 |
| `chameleonpaint_174` | #174 Chromatic Aberration Spray | 236 |
| `chameleonpaint_175` | #175 Its Christmas! Spray | 237 |
| `chameleonpaint_176` | #176 Temperature Spray | 238 |

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

Copy `install/ox_inventory_images/*.png` into `ox_inventory/web/images/`.

Restart `ox_inventory`.

### qb-core

Copy the item definitions from `install/qb-core_items.lua` into `qb-core/shared/items.lua`.

Copy the PNG files into your inventory images folder (`qb-inventory/html/images/` or `ps-inventory/html/images/`).

### ESX (without ox_inventory)

Run `install/esx_items.sql`.

5. Restart the server (or `ensure djfivem-spraypaint`).

## How to use in-game

1. Give yourself a spray: `/givechameleon 161` (admins) or spawn `chameleonpaint_161` from your admin menu.
2. Get in a vehicle as the driver.
3. Use the item from inventory.
4. After the progress bar, the car is chameleon-painted.
5. Store it in the garage and take it out — the paint should still be there.

`/chameleonpaints` lists every numbered spray.

## Config

Edit `config.lua`:

- `UseLegacyIndexes = true` if paints look **black** on an older game build (uses 161–176 instead of 223–238)
- `AllowInsideVehicle` / `AllowOutsideVehicle` — paint from the seat, from outside, or both
- `RequireOwnedVehicle = true` — only owned personal vehicles
- `ConsumeOnSuccess` — item is removed only if the paint actually applied
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
| `/givechameleon [161-176] [id] [count]` | admin | Give a numbered spray |
| `/chameleonpaints` | anyone | List all sprays |

## Exports

```lua
exports['djfivem-spraypaint']:GetPaints()
exports['djfivem-spraypaint']:GetSavedColor(plate)
exports['djfivem-spraypaint']:SaveChameleonPaint(plate, colorIndex)
```

## Troubleshooting

- **Car turns black:** set `sv_enforceGameBuild 2699` (or higher), restart, and confirm `data/` + `stream/` files are present. If still black, set `Config.UseLegacyIndexes = true`.
- **Item does nothing:** items were not added to ox_inventory/qb-core, or the resource folder was renamed (update the `export = 'djfivem-spraypaint.chameleonpaint'` line).
- **Paint vanishes in garage:** import `sql/install.sql`, start `oxmysql` before this resource, and keep `Config.KeepApplying = true`.
- **Sound missing:** this resource plays `html/spraypaint.ogg` itself. You do **not** need to move it to InteractSound.

## License

GNU GPL v3. See `LICENSE` and `COPYRIGHT`.

Based on [Testaross/chameleonpaint](https://github.com/Testaross/chameleonpaint). Credits: Testaross, MrZedo, Wildbrick142, Disquse, Rockstar Games.
