Config = {}

Config.UseOldEsx = false

Config.Notifications = 'ox'

Config.TimeToRobAgain = 60

Config.MinimumCops = 1

Config.PoliceJobs = { 'police', 'sheriff', 'fib' }

Config.BlacklistedJobs = { "police", "ambulance", "sheriff", "safd", "fib" }

Config.PoliceAlertProbability = 35

Config.ResistanceChance = 25

Config.NameWeaponNPC = "weapon_snspistol_mk2" -- https://wiki.rage.mp/index.php?title=Weapons [Handguns]

Config.CheckUpdate = false

Config.BlacklistNpc = { 
    [GetHashKey('mp_m_shopkeep_01')] = true
}

Config.Items = {
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

Strings = {
    ['racket'] = 'Roba a esta persona',
    ['can_rob_npc_again'] = 'No puedes robar a la misma persona dos veces',
    ['rob_complete'] = 'Has robado a esta persona',
    ['police_alert'] = '¡Un ciudadano está siendo asaltado, ayúdalo!',
    ['police_alert_blip'] = 'Asalto',
    ['need_police'] = 'No hay suficientes oficiales de policía en la ciudad.',
    ['rob_cooldown'] = 'Debes esperar ',
    ['to_far'] = 'La persona está demasiado lejos y huye ',
}