local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isSearching = false
local lastSearchTime = 0
local searchedBins = {} -- Track individual bins and their search times

-- PED AND BLIP FOR BIN BUYER
local binBuyerPed = nil
local binBuyerBlip = nil

-- Function to spawn bin buyer
local function SpawnBinBuyer()
    if not Config.EnableBinBuyer then return end
    
    -- Fallback ped models in case the main one fails
    local pedModels = {
        Config.BinBuyer.pedModel,
        's_m_m_janitor',
        's_m_m_worker',
        's_m_m_trucker_01',
        's_m_m_autoshop_01'
    }
    
    local pedModel = nil
    local attempts = 0
    
    -- Try to load one of the ped models
    for _, modelName in pairs(pedModels) do
        local modelHash = GetHashKey(modelName)
        RequestModel(modelHash)
        
        attempts = 0
        while not HasModelLoaded(modelHash) and attempts < 30 do
            Wait(100)
            attempts = attempts + 1
        end
        
        if HasModelLoaded(modelHash) then
            pedModel = modelHash
            print('^2[BinSearching] Successfully loaded ped model: ' .. modelName .. '^0')
            break
        else
            print('^3[BinSearching] Failed to load ped model: ' .. modelName .. '^0')
        end
    end
    
    if not pedModel then
        print('^1[BinSearching] Failed to load any ped model. Bin buyer will not spawn.^0')
        return
    end
    
    -- Spawn ped
    binBuyerPed = CreatePed(4, pedModel, Config.BinBuyer.coords.x, Config.BinBuyer.coords.y, Config.BinBuyer.coords.z - 1.0, Config.BinBuyer.heading, false, true)
    
    if DoesEntityExist(binBuyerPed) then
        SetEntityInvincible(binBuyerPed, true)
        SetBlockingOfNonTemporaryEvents(binBuyerPed, true)
        FreezeEntityPosition(binBuyerPed, true)
        SetEntityAsMissionEntity(binBuyerPed, true, true)
        
        -- Add blip
        binBuyerBlip = AddBlipForCoord(Config.BinBuyer.coords.x, Config.BinBuyer.coords.y, Config.BinBuyer.coords.z)
        SetBlipSprite(binBuyerBlip, Config.BinBuyer.blip.sprite)
        SetBlipDisplay(binBuyerBlip, 4)
        SetBlipScale(binBuyerBlip, Config.BinBuyer.blip.scale)
        SetBlipColour(binBuyerBlip, Config.BinBuyer.blip.color)
        SetBlipAsShortRange(binBuyerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.BinBuyer.blip.name)
        EndTextCommandSetBlipName(binBuyerBlip)
        
        print('^2[BinSearching] Bin buyer spawned successfully at ' .. Config.BinBuyer.coords.x .. ', ' .. Config.BinBuyer.coords.y .. ', ' .. Config.BinBuyer.coords.z .. '^0')
    else
        print('^1[BinSearching] Failed to spawn bin buyer ped^0')
    end
    
    SetModelAsNoLongerNeeded(pedModel)
end

-- Spawn bin buyer when player loads
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    Wait(2000) -- Wait for everything to load
    SpawnBinBuyer()
end)

-- Spawn bin buyer on resource start (for players already loaded)
CreateThread(function()
    Wait(3000) -- Wait for everything to initialize
    if LocalPlayer.state.isLoggedIn then
        SpawnBinBuyer()
    end
end)

-- OX_TARGET INTERACTION
CreateThread(function()
    Wait(5000) -- Wait for ped to spawn
    if Config.EnableBinBuyer and Config.Target == 'ox_target' and binBuyerPed and DoesEntityExist(binBuyerPed) then
        exports.ox_target:addLocalEntity(binBuyerPed, {
            {
                name = 'sell_bin_items',
                icon = 'fa-solid fa-recycle',
                label = 'Sell Bin Items',
                onSelect = function()
                    OpenBinSellMenu()
                end
            }
        })
        print('^2[BinSearching] Bin buyer target added successfully^0')
    end
end)

-- SELL MENU (choose UI)
function OpenBinSellMenu()
    if Config.SellMenu == 'ox_lib' then
        OpenBinSellMenu_OxLib()
    elseif Config.SellMenu == 'qb' then
        OpenBinSellMenu_QB()
    elseif Config.SellMenu == 'custom' then
        OpenBinSellMenu_Custom()
    end
end

-- OX_LIB CONTEXT MENU
function OpenBinSellMenu_OxLib()
    local items = {}
    local playerItems = exports.ox_inventory:Items() or {}
    for item, price in pairs(Config.BinSellPrices) do
        local count = 0
        for _, invItem in pairs(playerItems) do
            if invItem.name == item then
                count = invItem.count
                break
            end
        end
        table.insert(items, {
            title = (QBCore.Shared and QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label) or item,
            description = (count > 0 and ("You have: "..count) or "You have none"),
            icon = "fa-solid fa-box",
            disabled = (count == 0),
            onSelect = function()
                OpenBinSellInput(item, count, price)
            end
        })
    end
    lib.registerContext({
        id = 'bin_sell_menu',
        title = 'Sell Bin Items',
        options = items
    })
    lib.showContext('bin_sell_menu')
end

-- QB-MENU
function OpenBinSellMenu_QB()
    local playerItems = exports.ox_inventory:Items() or {}
    local sellItems = {}
    
    for item, price in pairs(Config.BinSellPrices) do
        local count = 0
        for _, invItem in pairs(playerItems) do
            if invItem.name == item then
                count = invItem.count
                break
            end
        end
        
        local label = (QBCore.Shared and QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label) or item
        local itemLabel = count > 0 and (label .. ' (x' .. count .. ')') or (label .. ' (None)')
        
        table.insert(sellItems, {
            header = itemLabel,
            txt = 'Price: ' .. (Config.CurrencySymbol or '$') .. price .. ' each',
            icon = 'fas fa-box',
            disabled = count <= 0,
            params = {
                event = 'binsearching:openSellInput',
                args = {
                    item = item,
                    count = count,
                    price = price,
                    label = label
                }
            }
        })
    end
    
    exports['qb-menu']:openMenu(sellItems)
end

-- QB-MENU Input Dialog
RegisterNetEvent('binsearching:openSellInput', function(data)
    if data.count <= 0 then return end
    
    local dialog = exports['qb-input']:ShowInput({
        header = 'Sell ' .. data.label,
        submitText = 'Sell',
        inputs = {
            {
                text = 'Amount to sell (max: ' .. data.count .. ')',
                name = 'amount',
                type = 'number',
                isRequired = true,
                default = 1
            }
        }
    })
    
    if dialog and dialog.amount then
        local amount = tonumber(dialog.amount)
        if amount and amount > 0 and amount <= data.count then
            TriggerServerEvent('binsearching:sellBinItem', data.item, amount)
        else
            QBCore.Functions.Notify('Invalid amount!', 'error')
        end
    end
end)

-- CUSTOM NUI
function OpenBinSellMenu_Custom()
    local playerItems = exports.ox_inventory:Items() or {}
    local sellItems = {}
    for item, price in pairs(Config.BinSellPrices) do
        local count = 0
        for _, invItem in pairs(playerItems) do
            if invItem.name == item then
                count = invItem.count
                break
            end
        end
        table.insert(sellItems, {
            name = item,
            label = (QBCore.Shared and QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label) or item,
            count = count,
            price = price
        })
    end
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openSellShop',
        items = sellItems,
        currency = Config.CurrencySymbol or '$'
    })
end

RegisterNUICallback('closeSellShop', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('sellItem', function(data, cb)
    if data and data.item and data.amount then
        TriggerServerEvent('binsearching:sellBinItem', data.item, data.amount)
        -- Refresh the UI after selling
        Wait(500) -- Wait for server to process
        OpenBinSellMenu_Custom()
    end
    cb('ok')
end)

function OpenBinSellInput(item, count, price)
    local label = (QBCore.Shared and QBCore.Shared.Items[item] and QBCore.Shared.Items[item].label) or item
    local symbol = Config.CurrencySymbol or '$'
    local input = lib.inputDialog('Sell '..label, {
        {
            type = 'number',
            label = 'Amount to Sell (max: '..count..')',
            min = 1,
            max = count,
            required = true
        }
    })
    if input and input[1] and tonumber(input[1]) and tonumber(input[1]) > 0 and tonumber(input[1]) <= count then
        TriggerServerEvent('binsearching:sellBinItem', item, tonumber(input[1]))
    end
end

-- Initialize NUI interface
local function InitializeNUI()
    SetNuiFocus(false, false)
end

-- Initialize when resource starts
CreateThread(function()
    InitializeNUI()
end)

-- Print a large banner on resource start
CreateThread(function()
    print('')
    print('===========================================')
    print('   MADE BY PINGU - TIKTOK LGNRP')
    print('===========================================')
    print('')
end)

-- Function to check if player is near a bin
local function IsNearBin()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    for _, model in pairs(Config.BinModels) do
        local binHash = type(model) == 'string' and GetHashKey(model) or model
        local bin = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, Config.MaxDistance, binHash, false, false, false)
        
        if bin ~= 0 then
            return true, bin
        end
    end
    
    return false, nil
end

-- Function to check if a specific bin can be searched
local function CanSearchBin(binEntity)
    if not searchedBins[binEntity] then
        return true
    end
    
    local currentTime = GetGameTimer()
    return (currentTime - searchedBins[binEntity]) >= Config.BinCooldown
end

-- Function to mark a bin as searched
local function MarkBinAsSearched(binEntity)
    searchedBins[binEntity] = GetGameTimer()
end

local function GetRandomItem()
    local totalChance = 0
    for _, item in pairs(Config.BinItems) do
        totalChance = totalChance + item.chance
    end
    
    local random = math.random(1, 100)
    local currentChance = 0
    
    for _, item in pairs(Config.BinItems) do
        currentChance = currentChance + item.chance
        if random <= currentChance then
            local amount = math.random(item.amount[1], item.amount[2])
            return item.item, amount
        end
    end
    
    return nil, 0
end

local function ShowNotification(message, type)
    if Config.Notify == 'ox_lib' then
        lib.notify({
            title = 'Bin Searching',
            description = message,
            type = type or 'inform'
        })
    else
        QBCore.Functions.Notify(message, type or 'primary')
    end
end

local function PlaySearchSound()
    -- Play the custom searching sound effect
    SendNUIMessage({
        type = "playSound"
    })
end

local function ShowProgressBar(callback)
    if Config.Progressbar == 'ox_lib' then
        if lib.progressBar({
            duration = Config.SearchTime,
            label = 'Searching bin...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'amb@prop_human_bum_bin@base',
                clip = 'base'
            }
        }) then
            callback()
        end
    else
        QBCore.Functions.Progressbar("searching_bin", 'Searching bin...', Config.SearchTime, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@prop_human_bum_bin@base",
            anim = "base",
            flags = 49,
        }, {}, {}, function() -- Done
            callback()
        end, function() -- Cancel
            ShowNotification('Search cancelled', 'error')
        end)
    end
end

-- Function to search bin
local function SearchBin()
    if isSearching then
        ShowNotification('You are already searching a bin', 'error')
        return
    end
    
    local nearBin, binEntity = IsNearBin()
    if not nearBin then
        ShowNotification('No bin nearby', 'error')
        return
    end
    
    -- Check if this specific bin can be searched
    if not CanSearchBin(binEntity) then
        local remainingTime = math.ceil((Config.BinCooldown - (GetGameTimer() - searchedBins[binEntity])) / 1000)
        ShowNotification('This bin was recently searched. Wait ' .. remainingTime .. ' seconds.', 'error')
        return
    end
    
    isSearching = true
    
    -- Play search sound
    PlaySearchSound()
    
    ShowProgressBar(function()
        isSearching = false
        
        -- Mark this specific bin as searched
        MarkBinAsSearched(binEntity)
        
        -- Stop any ongoing animations/scenarios
        local playerPed = PlayerPedId()
        ClearPedTasks(playerPed)
        
        local item, amount = GetRandomItem()
        if item and amount > 0 then
            if Config.Inventory == 'ox_inventory' then
                TriggerServerEvent('binsearching:server:giveItem', item, amount)
            else
                TriggerServerEvent('QBCore:Server:AddItem', item, amount)
            end
            
            ShowNotification('You found ' .. amount .. 'x ' .. item, 'success')
        else
            ShowNotification('You found nothing', 'inform')
        end
    end)
end

-- Event Handlers
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
end)

RegisterNetEvent('binsearching:client:searchBin', function()
    SearchBin()
end)

RegisterNetEvent('binsearching:client:notify', function(data)
    if Config.Notify == 'ox_lib' then
        lib.notify({
            title = data.title or 'Bin Searching',
            description = data.message,
            type = data.type or 'inform'
        })
    else
        QBCore.Functions.Notify(data.message, data.type or 'primary')
    end
end)

-- Commands
-- Remove the /searchbin command registration and handler
-- RegisterCommand('searchbin', function()
--     SearchBin()
-- end, false)

RegisterCommand('checkbins', function()
    local nearBin, binEntity = IsNearBin()
    if nearBin then
        ShowNotification('Bin found', 'success')
    else
        ShowNotification('No bins nearby', 'error')
    end
end, false)

-- Target System
if Config.Target == 'ox_target' then
    for _, model in pairs(Config.BinModels) do
        local binHash = type(model) == 'string' and GetHashKey(model) or model
        exports.ox_target:addModel(binHash, {
            {
                name = 'search_bin',
                icon = 'fas fa-search',
                label = 'Search Bin',
                onSelect = function()
                    SearchBin()
                end,
                canInteract = function()
                    if isSearching then
                        return false
                    end
                    
                    local nearBin, binEntity = IsNearBin()
                    if not nearBin then
                        return false
                    end
                    
                    return CanSearchBin(binEntity)
                end
            }
        })
    end
else
    exports['qb-target']:AddTargetModel(Config.BinModels, {
        options = {
            {
                type = "client",
                event = "binsearching:client:searchBin",
                icon = "fas fa-search",
                label = 'Search Bin',
                canInteract = function()
                    if isSearching then
                        return false
                    end
                    
                    local nearBin, binEntity = IsNearBin()
                    if not nearBin then
                        return false
                    end
                    
                    return CanSearchBin(binEntity)
                end
            },
        },
        distance = Config.MaxDistance,
    })
end

-- Resource Stop Handler
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Clean up ped and blip
        if binBuyerPed and DoesEntityExist(binBuyerPed) then
            DeleteEntity(binBuyerPed)
        end
        if binBuyerBlip then
            RemoveBlip(binBuyerBlip)
        end
        
        if Config.Notify == 'ox_lib' then
            lib.notify({
                title = 'Bin Searching',
                description = 'Resource stopped',
                type = 'error'
            })
        else
            QBCore.Functions.Notify('Resource stopped', 'error')
        end
    end
end)