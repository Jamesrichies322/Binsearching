Config = {}

-- General Settings
Config.Target = 'ox_target' -- OX_TARGET OR QB-TARGET
Config.Inventory = 'ox_inventory' -- OX_INVENTORY OR QB-INVENTORY
Config.Notify = 'ox_lib' -- Options: 'ox_lib', 'qb'
Config.Progressbar = 'ox_lib' -- Options: 'ox_lib', 'qb'
Config.SellMenu = 'custom' -- Options: 'ox_lib', 'qb', 'custom'

-- Language Settings
Config.Language = 'en' -- Default language (en, es, fr, de, pt, it, ru, zh, ja, ko)

Config.SearchTime = 5000 -- Time in ms to search a bin
Config.SearchCooldown = 30000 -- Cooldown between searches in ms
Config.BinCooldown = 120000 -- Cooldown for individual bins in ms (2 minutes)
Config.MaxDistance = 2.0 -- Maximum distance to interact with bins

-- Items that can be found in bins
Config.BinItems = {
    { item = 'water', amount = {1, 2}, chance = 45 },
    { item = 'sandwich', amount = {1, 1}, chance = 35 },
    { item = 'money', amount = {5, 25}, chance = 8 },
    { item = 'phone', amount = {1, 1}, chance = 3 },
    { item = 'lockpick', amount = {1, 1}, chance = 5 },
    { item = 'cigarette', amount = {1, 3}, chance = 25 },
    { item = 'lighter', amount = {1, 1}, chance = 12 },
    { item = 'newspaper', amount = {1, 2}, chance = 40 },
    { item = 'plastic_bottle', amount = {1, 3}, chance = 55 },
    { item = 'aluminum_can', amount = {1, 4}, chance = 60 },
    { item = 'coffee_cup', amount = {1, 2}, chance = 30 },
    { item = 'receipt', amount = {1, 3}, chance = 20 },
    { item = 'bandage', amount = {1, 1}, chance = 8 },
    { item = 'joint', amount = {1, 1}, chance = 4 },
    { item = 'broken_phone', amount = {1, 1}, chance = 2 },
    { item = 'empty_wallet', amount = {1, 1}, chance = 3 },
    { item = 'old_keys', amount = {1, 1}, chance = 6 },
    { item = 'scrap_metal', amount = {1, 2}, chance = 15 },
    { item = 'broken_glass', amount = {1, 3}, chance = 10 }
}

-- Bin Models that can be searched
Config.BinModels = {
    `prop_bin_01a`,
    "prop_dumpster_01a",
    "prop_dumpster_01a",
    "prop_dumpster_02a",
    "prop_dumpster_02b"
}

Config.BinSellPrices = {
    water = 2,
    sandwich = 3,
    cigarette = 1,
    lighter = 5,
    newspaper = 1,
    plastic_bottle = 1,
    aluminum_can = 1,
    coffee_cup = 1,
    receipt = 0,
    bandage = 5,
    joint = 10,
    broken_phone = 2,
    empty_wallet = 1,
    old_keys = 1,
    scrap_metal = 8,
    broken_glass = 1,
    phone = 20,
    lockpick = 10
}

-- Bin Buyer Settings
Config.EnableBinBuyer = true -- Enable/disable the bin buyer ped and blip
Config.BinBuyer = {
    coords = vector3(748.95, -1399.66, 26.59),
    heading = 180.0,
    pedModel = 's_m_m_janitor', -- Changed to a valid ped model
    blip = {
        sprite = 605,
        color = 2,
        scale = 0.8,
        name = 'Recycler (Sell Bin Items)'
    }
}

Config.CurrencySymbol = '£' -- Set your preferred currency symbol here 