-------------------------------------
------- Created by T1GER#9080 -------
------------------------------------- 
ESX 		= nil
PlayerData 	= {}
isCop 		= false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.ESX_OBJECT, function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
	isCop = IsPlayerJobCop()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job
	isCop = IsPlayerJobCop()
end)

-- Notification
RegisterNetEvent('t1ger_drugs:notify')
AddEventHandler('t1ger_drugs:notify', function(msg)
	ESX.ShowNotification(msg)
end)

-- Advanced Notification
RegisterNetEvent('t1ger_drugs:notifyAdvanced')
AddEventHandler('t1ger_drugs:notifyAdvanced', function(sender, subject, msg, textureDict, iconType)
	ESX.ShowAdvancedNotification(sender, subject, msg, textureDict, iconType, false, false, false)
end)

-- Job Notification
RegisterNetEvent('t1ger_drugs:job_notify')
AddEventHandler('t1ger_drugs:job_notify', function(msg)
	if Config.DrugJobs.Settings.phoneMSG then
		local phone_number = Config.DrugJobs.NPC.name
		PlaySoundFrontend(-1, "Menu_Accept", "Phone_SoundSet_Default", true)
		TriggerEvent('t1ger_drugs:notify', (Lang['new_msg_from']:format(phone_number)))
		TriggerServerEvent('gcPhone:sendMessage', phone_number, msg)
	else
		TriggerEvent('t1ger_drugs:notify', msg)
	end
end)

-- Police Notification
RegisterNetEvent('t1ger_drugs:police_notify')
AddEventHandler('t1ger_drugs:police_notify', function(msg)
	if Config.Police.Alerts.enable then
		local coords = GetEntityCoords(GetPlayerPed(-1), false)
		local street_name = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
		TriggerServerEvent('t1ger_drugs:sendPoliceAlert', coords, street_name, msg)
	end
end)

-- Police Notification Blip:
RegisterNetEvent('t1ger_drugs:sendPoliceAlertCL')
AddEventHandler('t1ger_drugs:sendPoliceAlertCL', function(target_coords, message)
	if isCop then
		TriggerEvent('chat:addMessage', { args = {(Lang['dispatch_name']).. message}})
		-- blip
		local cfg = Config.Blips['police']
		if cfg.show then
			local alpha = cfg.alpha
			local blip = AddBlipForRadius(target_coords.x, target_coords.y, target_coords.z, cfg.radius)
			SetBlipHighDetail(blip, true)
			SetBlipColour(blip, cfg.color)
			SetBlipAlpha(blip, alpha)
			SetBlipAsShortRange(blip, true)
			while alpha ~= 0 do
				Citizen.Wait(cfg.time * 4)
				alpha = alpha - 1
				SetBlipAlpha(blip, alpha)
				if alpha == 0 then
					RemoveBlip(blip)
					return
				end
			end
		end
	end
end)

-- Is Player A cop?
function IsPlayerJobCop()	
	if not PlayerData then return false end
	if not PlayerData.job then return false end
	for k,v in pairs(Config.Police.Jobs) do
		if PlayerData.job.name == v then return true end
	end
	return false
end

-- Draw 3D Text:
function T1GER_DrawTxt(x, y, z, text)
	local boolean, _x, _y = GetScreenCoordFromWorldCoord(x, y, z)
    SetTextScale(0.32, 0.32); SetTextFont(4); SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING"); SetTextCentre(1); AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text) / 500)
    DrawRect(_x, (_y + 0.0125), (0.015 + factor), 0.03, 0, 0, 0, 80)
end

-- Create Blip:
function T1GER_CreateBlip(pos, data)
	local blip = nil
	if data.enable then 
		blip = AddBlipForCoord(pos.x, pos.y, pos.z)
		SetBlipSprite(blip, data.sprite)
		SetBlipDisplay(blip, data.display)
		SetBlipScale(blip, data.scale)
		SetBlipColour(blip, data.color)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(data.label)
		EndTextCommandSetBlipName(blip)
		if data.route then 
			SetBlipRoute(blip, data.route)
			SetBlipRouteColour(blip, data.color)
		end
	end
	return blip
end

-- Create Vehicle:
function T1GER_CreateVehicle(model, pos, heading)
	T1GER_LoadModel(model)
    local vehicle = CreateVehicle(model, pos.x, pos.y, pos.z, heading, true, false)
	NetworkRegisterEntityAsNetworked(vehicle)
	SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(vehicle), true)
	SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(vehicle), true)
    SetVehicleNeedsToBeHotwired(vehicle, true)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleDoorsLockedForAllPlayers(vehicle, true)
    SetVehicleIsStolen(vehicle, false)
    SetVehicleIsWanted(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleFuelLevel(vehicle, 80.0)
    DecorSetFloat(vehicle, "_FUEL_LEVEL", GetVehicleFuelLevel(vehicle))
	SetVehicleOnGroundProperly(vehicle)
    return vehicle
end

function T1GER_GetControlOfEntity(entity)
	local netTime = 15
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) and netTime > 0 do 
		NetworkRequestControlOfEntity(entity)
		Citizen.Wait(100)
		netTime = netTime -1
	end
end

-- Function to create job ped(s):
function T1GER_CreatePed(type, model, x, y, z, heading)
	T1GER_LoadModel(model)
	local NPC = CreatePed(type, GetHashKey(model), x, y, z, heading, true, true)
	SetEntityAsMissionEntity(NPC)
	return NPC
end

-- Load Anim
function T1GER_LoadAnim(animDict)
	RequestAnimDict(animDict); while not HasAnimDictLoaded(animDict) do Citizen.Wait(1) end
end

-- Load Model
function T1GER_LoadModel(model)
	RequestModel(model); while not HasModelLoaded(model) do Citizen.Wait(1) end
end
