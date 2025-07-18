local WebHook = ''

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

    for jobName, _ in pairs(Config.PoliceJobs) do
        cops = cops + ESX.GetNumPlayers('job', jobName)
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

        local embedData = {
            embeds = {{
                title = "NPC Robado",
                color = 16753920, -- Orange
                fields = {
                    { name = "Jugador con ID", value = tostring(source), inline = true },
                    { name = "Item Robado", value = itemName, inline = true },
                    { name = "Cantidad", value = tostring(itemAmount), inline = true }
                },
                footer = {
                    text = "Sistema de Robo NPC"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }

        PerformHttpRequest(WebHook,
            function(err, text, headers)
            end, 'POST', json.encode(embedData),
            { ['Content-Type'] = 'application/json' }
        )
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