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

ped = {}

local function policeAlert()
    local alertLuck = math.random(100)
    if alertLuck <= Config.PoliceAlertProbability then
        TriggerServerEvent('Muhaddil-NPCRob:server:policeAlert', GetEntityCoords(PlayerPedId()))
    end
end

local function isBlacklisted(model)
    return Config.BlacklistNpc[model] == true
end

function isJobBlacklisted()
    local playerJob = ESX.GetPlayerData().job.name
    return Config.PoliceJobs[playerJob] == true
end

function Notify(msg, typenotif)
    if Config.Notify == 'ox' then
        lib.notify({
            title = "Robo",
            description = msg,
            showDuration = true,
            type = typenotif,
            duration = 5000
        })
    elseif Config.Notify == 'okok' then
        exports['okokNotify']:Alert("", msg, 5000, typenotif)
    elseif Config.Notify == 'esx' then
        ESX.ShowNotification(msg)
    end
end

local currentNpcEntity = nil
local lastRobberyTime = 0
local handsup = false
local hastofollow = false

lib.registerContext({
    id = 'npc_interaction_menu',
    title = 'Interacción con NPC',
    options = {
        {
            title = 'Robar',
            icon = 'fa-solid fa-hand-holding',
            onSelect = function()
                if currentNpcEntity then
                    TriggerEvent('Muhaddil-NPCRob:client:rob', currentNpcEntity)
                    handsup = false
                    hastofollow = false
                else
                    print("No se ha seleccionado un NPC válido")
                end
            end
        },
        {
            title = 'Seguir',
            icon = 'fa-solid fa-user-plus',
            onSelect = function()
                if currentNpcEntity then
                    hastofollow = true
                    handsup = false
                    FollowPlayer(currentNpcEntity)
                else
                    print("No se ha seleccionado un NPC válido")
                end
            end
        },
        {
            title = 'Quedarse quieto',
            icon = 'fa-solid fa-pause',
            onSelect = function()
                if currentNpcEntity then
                    handsup = true
                    hastofollow = false
                    TaskStandStill(currentNpcEntity, -1)
                    HandsUp(currentNpcEntity)
                    FreezeEntityPosition(currentNpcEntity, true)
                else
                    print("No se ha seleccionado un NPC válido")
                end
            end
        },
        {
            title = 'Irse',
            icon = 'fa-solid fa-walking',
            onSelect = function()
                if currentNpcEntity then
                    FreezeEntityPosition(currentNpcEntity, false)
                    handsup = false
                    hastofollow = false
                    ClearPedTasks(currentNpcEntity)
                    TaskSmartFleePed(currentNpcEntity, PlayerPedId(), 150.0, -1, 0, 0)
                    currentNpcEntity = nil
                else
                    print("No se ha seleccionado un NPC válido")
                end
            end
        }
    }
})

function FollowPlayer(npc)
    FreezeEntityPosition(npc, false)
    Citizen.CreateThread(function()
        local following = false
        while hastofollow do
            Citizen.Wait(100)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local npcCoords = GetEntityCoords(npc)
            local distance = #(playerCoords - npcCoords)

            if distance > 2.0 then
                if not following then
                    ClearPedTasks(npc)
                    TaskFollowToOffsetOfEntity(npc, playerPed, 0.0, 0.0, 0.0, 7.0, -1, 0.5, true)
                    following = true
                end
            else
                if following then
                    ClearPedTasks(npc)
                    TaskGoToEntity(npc, playerPed, -1, 0.5, 2.0, 1073741824, 0)
                    following = false
                end
            end

            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if not IsPedInVehicle(npc, vehicle, false) then
                    ClearPedTasks(npc)
                    local seat = 0
                    TaskWarpPedIntoVehicle(npc, vehicle, seat)
                end
            end
        end
    end)
end

function HandsUp(npc)
    FreezeEntityPosition(npc, true)
    Citizen.CreateThread(function()
        while handsup do
            Citizen.Wait(100)
            ClearPedTasks(npc)

            local animDict = "random@mugging3"
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(100)
            end

            TaskPlayAnim(npc, animDict, "handsup_standing_base", 8.0, 8.0, -1, 1, 0, false, false, false)

            Citizen.Wait(3000)
        end
    end)
end

exports.ox_target:addGlobalPed({
    {
        name = 'npc-rob',
        label = 'Interactuar con NPC',
        icon = 'fa-solid fa-male',
        canInteract = function(entity)
            local pedType = GetPedType(entity)
            return IsPedArmed(PlayerPedId(), 7) and (pedType == 4 or pedType == 5 or pedType == 6) and not isBlacklisted(GetEntityModel(entity))
        end,
        onSelect = function(data)
            currentNpcEntity = data.entity
            lib.showContext('npc_interaction_menu')
        end
    }
})

RegisterNetEvent('Muhaddil-NPCRob:client:rob', function(data)
    local currentTime = GetGameTimer() / 1000
    if currentTime - lastRobberyTime < Config.TimeToRobAgain then
        Notify(Strings['rob_cooldown'], 'error')
        return
    end
    lastRobberyTime = currentTime

    ESX.TriggerServerCallback('Muhaddil-NPCRob:amount', function(tooFewCops)
        if tooFewCops then
            Notify(Strings['need_police'], 'error')
            return
        end

        local chance = math.random(100)
        if ped[data] then
            Notify(Strings['can_rob_npc_again'], 'error')
            return
        end

        local playerPed = PlayerPedId()
        local isMelee = IsPedArmed(playerPed, 1)

        if IsPedArmed(playerPed, 1 | 2 | 4) and not isJobBlacklisted() then
            local entityId = NetworkGetNetworkIdFromEntity(data)
            SetBlockingOfNonTemporaryEvents(data, true)
            ped[data] = true

            local animDictp, animNamep
            if isMelee then
                animDictp = 'weapons@first_person@aim_stealth@generic@melee@large_wpn@gclub@core'
                animNamep = 'aim_med_loop'
            else
                animDictp = 'weapons@pistol@'
                animNamep = 'settle_med'
            end

            RequestAnimDict(animDictp)
            while not HasAnimDictLoaded(animDictp) do
                Wait(100)
            end

            TaskTurnPedToFaceEntity(playerPed, data, 0)
            Wait(700)

            local success = lib.progressBar({
                duration = 5000,
                label = 'Amenazando...',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    move = true,
                    combat = true,
                    sprint = true,
                },
                anim = {
                    dict = animDictp,
                    clip = animNamep,
                }
            })

            TaskPlayAnim(playerPed, animDictp, animNamep, 8.0, -8.0, 1000, 1, 1, false, false, false)

            if not success then
                Notify("Robo cancelado", 'error')
                return
            end

            local endTime = GetGameTimer() + 1000
            while GetGameTimer() < endTime do
                if not IsEntityPlayingAnim(data, "random@mugging3", "handsup_standing_base", 3) then
                    TaskHandsUp(data, endTime - GetGameTimer(), PlayerPedId(), 0, true)
                end
                Wait(100)
            end

            FreezeEntityPosition(data, false)
            TaskGoToEntity(data, PlayerPedId(), -1, 0.5, 1.0, 1073741824, 0)

            if chance <= Config.ResistanceChance then
                local weaponHash = GetHashKey(Config.NameWeaponNPC)
                GiveWeaponToPed(data, weaponHash, 200, false, true)
                SetPedRelationshipGroupHash(data, GetHashKey("ENEMY"))
                TaskCombatPed(data, playerPed, 0, 16)
                policeAlert()
                return
            end

            while GetDistanceBetweenCoords(GetEntityCoords(data), GetEntityCoords(PlayerPedId()), true) > 1.0 do
                Wait(100)
                if GetDistanceBetweenCoords(GetEntityCoords(data), GetEntityCoords(PlayerPedId()), true) > 5.0 then
                    break
                end
            end

            if GetDistanceBetweenCoords(GetEntityCoords(data), GetEntityCoords(PlayerPedId()), true) <= 5.0 then
                local animDict = 'mp_common'
                RequestAnimDict(animDict)
                while not HasAnimDictLoaded(animDict) do
                    Wait(100)
                end
                TaskPlayAnim(data, animDict, 'givetake2_a', 8.0, -8.0, -1, 32, 0, false, false, false)
                TaskPlayAnim(playerPed, animDict, 'givetake2_a', 8.0, -8.0, 2000, 32, 0, false, false, false)
                Wait(2000)
                TriggerServerEvent('Muhaddil-NPCRob:server:robNpc', NetworkGetNetworkIdFromEntity(data))
                Notify(Strings['rob_complete'], 'success')
            else
                Notify(Strings['to_far'], 'error')
            end

            handsup = false
            hastofollow = false
            ClearPedTasksImmediately(data)
            SetBlockingOfNonTemporaryEvents(data, false)
            TaskSmartFleePed(data, PlayerPedId(), 50.0, 100000, 0, 0)
            currentNpcEntity = nil
            policeAlert()
        end
    end)
end)

Citizen.CreateThread(function()
    local menuOpen = false
    local activationDistance = 2.5

    while true do
        local timeout = 0
        local target = false
        Citizen.Wait(timeout)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if IsPedArmed(playerPed, 7) then
            local hit, hitEntity = GetEntityPlayerIsFreeAimingAt(PlayerId())

            local pedType = GetPedType(hitEntity)

            if hit and DoesEntityExist(hitEntity) and not IsPedAPlayer(hitEntity) and (pedType == 4 or pedType == 5 or pedType == 6) and not isBlacklisted(GetEntityModel(hitEntity)) then
                if not IsPedDeadOrDying(hitEntity, true) then
                    local npcCoords = GetEntityCoords(hitEntity)
                    local distance = #(playerCoords - npcCoords)

                    if distance <= activationDistance then
                        if not IsPedInAnyVehicle(hitEntity, false) then
                            if not menuOpen and not isJobBlacklisted() then
                                menuOpen = true
                                currentNpcEntity = hitEntity
                                target = true

                                ClearPedTasksImmediately(currentNpcEntity)
                                FreezeEntityPosition(currentNpcEntity, true)
                                SetBlockingOfNonTemporaryEvents(currentNpcEntity, true)
                                handsup = true
                                HandsUp(currentNpcEntity)

                                local animDict = "random@mugging3"
                                RequestAnimDict(animDict)

                                while not HasAnimDictLoaded(animDict) do
                                    Citizen.Wait(100)
                                end

                                TaskPlayAnim(currentNpcEntity, animDict, "handsup_standing_base", 8.0, 8.0, -1, 1, 0, false, false, false)
                                SetPedFleeAttributes(currentNpcEntity, 0, false)

                                Citizen.Wait(100)
                                lib.showContext('npc_interaction_menu')
                            end
                        end
                    end
                end
            else
                target = false
                menuOpen = false
            end
        else
            menuOpen = false
        end
    end
end)