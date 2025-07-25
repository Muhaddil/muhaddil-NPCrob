# Muhaddil NPC Robbery

## This script is WIP

A FiveM script that allows players to rob NPCs with immersive interactions, police alerts, and configurable rewards. Designed for ESX-based servers, supporting both old and new ESX versions.

## Features
- Rob NPCs with a contextual menu (rob, follow, stay, leave)
- Police alert system with configurable probability
- NPC resistance chance (NPC may fight back)
- Blacklist specific NPC models from being robbed
- Configurable rewards (items, amounts)
- Discord webhook logging for successful robberies
- Multiple notification systems supported (ox_lib, okokNotify, ESX)

## Requirements
- ESX (old or new)
- ox_lib
- ox_target
- okokNotify (optional, if using okok notifications)
- origen_police (for police alerts)

## Installation
1. Place the `Muhaddil-NPCrob` folder in your server's `resources` directory.
2. Ensure dependencies (`ox_lib`, `ox_target`, `es_extended`, etc.) are installed.
3. Add the following to your `server.cfg`:
   ```
   ensure Muhaddil-NPCrob
   ```
4. Configure `config.lua` to your preferences (items, police jobs, notification type, etc.).

## Configuration
Edit `config.lua` to:
- Set minimum police required
- Adjust robbery cooldown
- Change notification system
- Add or remove reward items
- Set police alert and resistance probabilities
- Blacklist NPC models

## Usage
- Aim at an NPC with a weapon to open the interaction menu.
- Choose to rob, make the NPC follow, stay, or leave.
- If robbing, a progress bar and animations will play. NPC may resist or alert police.
- Successful robberies are logged to Discord via webhook.