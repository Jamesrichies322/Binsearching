# Bin Searching Script

A simple FiveM script that allows players to search bins/dumpsters for random items and sell them at a recycler NPC. Supports both QBCore and ox_inventory, as well as ox_lib and QBCore notifications and menus.

## Features
- Search bins/dumpsters for random loot
- Configurable loot table and sell prices
- Sell found items at a recycler NPC (ped with blip)
- Supports both QBCore and ox_inventory
- Modern UI with ox_lib context menus and input dialogs
- Configurable currency symbol and notifications

## Configuration
- All settings are in `shared/config.lua`.
- Change `Config.CurrencySymbol` to set your preferred currency (e.g., '$', '€', '£').
- Edit `Config.BinItems` to control what can be found in bins.
- Edit `Config.BinSellPrices` to set which items can be sold and for how much.
- Enable/disable the recycler NPC and change its location/model/blip with `Config.EnableBinBuyer` and `Config.BinBuyer`.

## Items (Add to your inventory system)

### QBCore (shared/items.lua)
Add these entries if you use QBCore:
```lua
['water'] = {['name'] = 'water', ['label'] = 'Water Bottle', ['weight'] = 500, ['type'] = 'item', ['image'] = 'water.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A bottle of water'},
['sandwich'] = {['name'] = 'sandwich', ['label'] = 'Sandwich', ['weight'] = 300, ['type'] = 'item', ['image'] = 'sandwich.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A sandwich'},
['cigarette'] = {['name'] = 'cigarette', ['label'] = 'Cigarette', ['weight'] = 10, ['type'] = 'item', ['image'] = 'cigarette.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A single cigarette'},
['lighter'] = {['name'] = 'lighter', ['label'] = 'Lighter', ['weight'] = 50, ['type'] = 'item', ['image'] = 'lighter.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A disposable lighter'},
['newspaper'] = {['name'] = 'newspaper', ['label'] = 'Newspaper', ['weight'] = 200, ['type'] = 'item', ['image'] = 'newspaper.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'An old newspaper'},
['plastic_bottle'] = {['name'] = 'plastic_bottle', ['label'] = 'Plastic Bottle', ['weight'] = 100, ['type'] = 'item', ['image'] = 'plastic_bottle.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'An empty plastic bottle'},
['aluminum_can'] = {['name'] = 'aluminum_can', ['label'] = 'Aluminum Can', ['weight'] = 50, ['type'] = 'item', ['image'] = 'aluminum_can.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'An empty aluminum can'},
['coffee_cup'] = {['name'] = 'coffee_cup', ['label'] = 'Coffee Cup', ['weight'] = 150, ['type'] = 'item', ['image'] = 'coffee_cup.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'An empty coffee cup'},
['receipt'] = {['name'] = 'receipt', ['label'] = 'Receipt', ['weight'] = 5, ['type'] = 'item', ['image'] = 'receipt.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A crumpled receipt'},
['bandage'] = {['name'] = 'bandage', ['label'] = 'Bandage', ['weight'] = 100, ['type'] = 'item', ['image'] = 'bandage.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A medical bandage'},
['joint'] = {['name'] = 'joint', ['label'] = 'Joint', ['weight'] = 20, ['type'] = 'item', ['image'] = 'joint.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A marijuana joint'},
['broken_phone'] = {['name'] = 'broken_phone', ['label'] = 'Broken Phone', ['weight'] = 300, ['type'] = 'item', ['image'] = 'broken_phone.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A broken mobile phone'},
['empty_wallet'] = {['name'] = 'empty_wallet', ['label'] = 'Empty Wallet', ['weight'] = 100, ['type'] = 'item', ['image'] = 'empty_wallet.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'An empty wallet'},
['old_keys'] = {['name'] = 'old_keys', ['label'] = 'Old Keys', ['weight'] = 200, ['type'] = 'item', ['image'] = 'old_keys.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A set of old keys'},
['scrap_metal'] = {['name'] = 'scrap_metal', ['label'] = 'Scrap Metal', ['weight'] = 500, ['type'] = 'item', ['image'] = 'scrap_metal.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Some scrap metal pieces'},
['broken_glass'] = {['name'] = 'broken_glass', ['label'] = 'Broken Glass', ['weight'] = 100, ['type'] = 'item', ['image'] = 'broken_glass.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'Broken glass shards'},
['phone'] = {['name'] = 'phone', ['label'] = 'Phone', ['weight'] = 300, ['type'] = 'item', ['image'] = 'phone.png', ['unique'] = true, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A mobile phone'},
['lockpick'] = {['name'] = 'lockpick', ['label'] = 'Lockpick', ['weight'] = 100, ['type'] = 'item', ['image'] = 'lockpick.png', ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil, ['description'] = 'A lockpick'},
```

### ox_inventory (data/items.lua)
Add these entries if you use ox_inventory:
```lua
['water'] = {
    label = 'Water Bottle',
    weight = 500,
    stack = true,
    close = true,
    description = 'A bottle of water'
},

['sandwich'] = {
    label = 'Sandwich',
    weight = 300,
    stack = true,
    close = true,
    description = 'A sandwich'
},

['cigarette'] = {
    label = 'Cigarette',
    weight = 10,
    stack = true,
    close = true,
    description = 'A single cigarette'
},

['lighter'] = {
    label = 'Lighter',
    weight = 50,
    stack = true,
    close = true,
    description = 'A disposable lighter'
},

['newspaper'] = {
    label = 'Newspaper',
    weight = 200,
    stack = true,
    close = true,
    description = 'An old newspaper'
},

['plastic_bottle'] = {
    label = 'Plastic Bottle',
    weight = 100,
    stack = true,
    close = true,
    description = 'An empty plastic bottle'
},

['aluminum_can'] = {
    label = 'Aluminum Can',
    weight = 50,
    stack = true,
    close = true,
    description = 'An empty aluminum can'
},

['coffee_cup'] = {
    label = 'Coffee Cup',
    weight = 150,
    stack = true,
    close = true,
    description = 'An empty coffee cup'
},

['receipt'] = {
    label = 'Receipt',
    weight = 5,
    stack = true,
    close = true,
    description = 'A crumpled receipt'
},

['bandage'] = {
    label = 'Bandage',
    weight = 100,
    stack = true,
    close = true,
    description = 'A medical bandage'
},

['joint'] = {
    label = 'Joint',
    weight = 20,
    stack = true,
    close = true,
    description = 'A marijuana joint'
},

['broken_phone'] = {
    label = 'Broken Phone',
    weight = 300,
    stack = true,
    close = true,
    description = 'A broken mobile phone'
},

['empty_wallet'] = {
    label = 'Empty Wallet',
    weight = 100,
    stack = true,
    close = true,
    description = 'An empty wallet'
},

['old_keys'] = {
    label = 'Old Keys',
    weight = 200,
    stack = true,
    close = true,
    description = 'A set of old keys'
},

['scrap_metal'] = {
    label = 'Scrap Metal',
    weight = 500,
    stack = true,
    close = true,
    description = 'Some scrap metal pieces'
},

['broken_glass'] = {
    label = 'Broken Glass',
    weight = 100,
    stack = true,
    close = true,
    description = 'Broken glass shards'
},

-- Existing Items (if not already in your inventory)
['money'] = {
    label = 'Cash',
    weight = 0,
    stack = true,
    close = true,
    description = 'Some cash'
},

['phone'] = {
    label = 'Phone',
    weight = 300,
    stack = true,
    close = true,
    description = 'A mobile phone'
},

['lockpick'] = {
    label = 'Lockpick',
    weight = 100,
    stack = true,
    close = true,
    description = 'A lockpick'
},
```

- Adjust weights, images, and descriptions as needed for your server.
- Make sure to add images for each item in your inventory UI.

## Usage
- Search bins/dumpsters using the target system (ox_target or qb-target)
- Find random items based on your config
- Sell items at the recycler NPC (location and model are configurable)
- All notifications and menus use your chosen system (ox_lib or QBCore)

## Requirements
- QBCore Framework
- ox_lib (for modern UI)
- ox_inventory or qb-inventory
- ox_target or qb-target

## Credits
- Script by [Your Name]
- Uses ox_lib, QBCore, and ox_inventory 