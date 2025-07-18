Config = {}

Config.UseOldEsx = false -- Set to true if you are using an older version of ESX that requires the old method of getting the shared object.

Config.Notify = 'ox' -- Options: 'ox', 'esx', 'okok'

Config.TimeToRobAgain = 60 -- Time in seconds before the player can rob some NPCs again

Config.MinimumCops = 1 -- Minimum number of police officers required to rob an NPC

Config.PoliceJobs = { 'police', 'sheriff', 'fib' }

Config.BlacklistedJobs = { "police", "ambulance", "sheriff", "safd", "fib" }

Config.PoliceAlertProbability = 35 -- Probability of alerting the police when robbing an NPC

Config.ResistanceChance = 25 -- Chance of NPC resisting the robbery

Config.NameWeaponNPC = "weapon_snspistol_mk2" -- https://wiki.rage.mp/index.php?title=Weapons [Handguns]
-- This is the weapon that the NPC will use to defend themselves if they resist the robbery.

Config.CheckUpdate = false -- Unused, but can be used to check for updates in the future.

Config.BlacklistNpc = { -- NPCs that cannot be robbed
    [GetHashKey('mp_m_shopkeep_01')] = true
}

Config.Items = { -- Items that can be stolen from NPCs
    {
        itemName = 'black_money',
        itemRandomAmount = {100, 250}
    },
    {
        itemName = 'purplehaze_joint',
        itemRandomAmount = {1, 3}
    },
    {
        itemName = 'drug_lsd',
        itemRandomAmount = {1, 5} 
    },
}

Strings = { -- Strings used in the script
    ['racket'] = 'Roba a esta persona',
    ['can_rob_npc_again'] = 'No puedes robar a la misma persona dos veces',
    ['rob_complete'] = 'Has robado a esta persona',
    ['police_alert'] = '¡Un ciudadano está siendo asaltado, ayúdalo!',
    ['police_alert_blip'] = 'Asalto',
    ['need_police'] = 'No hay suficientes oficiales de policía en la ciudad.',
    ['rob_cooldown'] = 'Debes esperar ',
    ['to_far'] = 'La persona está demasiado lejos y huye ',
}