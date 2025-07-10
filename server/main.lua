local QBCore = exports['qb-core']:GetCoreObject()

-- Server event to add item to player inventory (for QB-Inventory)
RegisterNetEvent('QBCore:Server:AddItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    if Config.Inventory == 'ox_inventory' then
        -- For ox_inventory, items are handled client-side
        return
    else
        -- For QB-Inventory
        local success = Player.Functions.AddItem(item, amount)
        if success then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
        else
            SendNotification(src, 'Inventory is full!', 'error')
        end
    end
end)

-- Function to validate item exists in shared items
local function ValidateItem(item)
    if Config.Inventory == 'ox_inventory' then
        -- ox_inventory handles validation internally
        return true
    else
        return QBCore.Shared.Items[item] ~= nil
    end
end

-- Server event to give item with validation
RegisterNetEvent('binsearching:server:giveItem', function(item, amount)
    local src = source
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(src, item, amount)
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddItem(item, amount)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
            SendNotification(src, ('You found %s x %s!'):format(amount, QBCore.Shared.Items[item].label), 'success')
        else
            SendNotification(src, 'Inventory is full!', 'error')
        end
    end
end)

-- Export for other resources to use
exports('GetBinSearchConfig', function()
    return Config
end)

-- Event when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[BinSearching] Resource started successfully!^0')
        print('^3Target System: ' .. Config.Target .. '^0')
        print('^3Inventory System: ' .. Config.Inventory .. '^0')
        print('^3Menu System: ' .. Config.Menu .. '^0')
        print('^3Notify System: ' .. Config.Notify .. '^0')
        print('^3Progressbar System: ' .. Config.Progressbar .. '^0')
    end
end)

local function SendNotification(src, message, notifType, title)
    if Config.Notify == 'ox_lib' then
        TriggerClientEvent('binsearching:client:notify', src, {
            message = message,
            type = notifType,
            title = title or 'Bin Searching'
        })
    else
        TriggerClientEvent('QBCore:Notify', src, message, notifType)
    end
end

RegisterNetEvent('binsearching:sellBinItem', function(item, amount)
    local src = source
    local price = Config.BinSellPrices[item]
    local symbol = Config.CurrencySymbol or '$'
    if not price or amount < 1 then
        SendNotification(src, 'Invalid item or amount.', 'error')
        return
    end
    if Config.Inventory == 'ox_inventory' then
        local has = exports.ox_inventory:GetItem(src, item, nil, true)
        if not has or has < amount then
            SendNotification(src, 'You do not have enough '..item..' to sell.', 'error')
            return
        end
        local removed = exports.ox_inventory:RemoveItem(src, item, amount)
        if removed then
            exports.ox_inventory:AddItem(src, 'money', price * amount)
            SendNotification(src, 'Sold '..amount..'x '..item..' for '..symbol..(price*amount)..'!', 'success')
        else
            SendNotification(src, 'Failed to remove items.', 'error')
        end
    else
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end
        local invItem = Player.Functions.GetItemByName(item)
        if not invItem or invItem.amount < amount then
            SendNotification(src, 'You do not have enough '..item..' to sell.', 'error')
            return
        end
        local removed = Player.Functions.RemoveItem(item, amount)
        if removed then
            Player.Functions.AddMoney('cash', price * amount)
            SendNotification(src, 'Sold '..amount..'x '..item..' for '..symbol..(price*amount)..'!', 'success')
        else
            SendNotification(src, 'Failed to remove items.', 'error')
        end
    end
end)
