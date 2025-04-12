if Config.UseOldEsx then
    ESX = nil
    
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Citizen.Wait(0)
        end
    
        while ESX.GetPlayerData().job == nil do
            Citizen.Wait(10)
        end
    
        ESX.PlayerData = ESX.GetPlayerData()
    end)
else
    ESX = exports["es_extended"]:getSharedObject()
end

ESX.RegisterServerCallback('Muhaddil-NPCRob:amount', function(source, cb)
    local cops = 0

    for _, job in pairs(Config.PoliceJobs) do
        cops = cops + ESX.GetNumPlayers('job', job)
    end

    if cops >= Config.MinimumCops then
        cb(false)
    else
        cb(true)
    end
end)

local items = Config.Items

RegisterNetEvent('Muhaddil-NPCRob:server:robNpc', function(entityId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemIndex = math.random(1, #items)
    local itemName = items[itemIndex].itemName
    local itemAmount = math.random(items[itemIndex].itemRandomAmount[1], items[itemIndex].itemRandomAmount[2])

    if xPlayer then
        xPlayer.addInventoryItem(itemName, itemAmount)
        local message = string.format("**Jugador con ID:** %d\n**Robó Item:** %s\n**Cantidad de Item:** %d", source,
            itemName, itemAmount)
        PerformHttpRequest(
        'https://discord.com/api/webhooks/1112330138743488512/HotHAxkKD8-WcSlz9Cuz1XNG74CFTrQThzGR_2ez-POal6dFBi1Ega_lbQPEc0wDuQ3V',
            function(err, text, headers)
            end, 'POST', json.encode({
            content = message
        }), { ['Content-Type'] = 'application/json' })
    end
end)

RegisterNetEvent('Muhaddil-NPCRob:server:policeAlert', function (pos)
    local message = 'Alguien ha asaltado a una persona'
    exports['origen_police']:SendAlert({
        coords = pos,
        title = 'Alerta de Robo',
        type = '48X',
        message = message,
        job = 'police',
    })
end)