ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
	ESX = obj
end)

RegisterServerEvent('esx_clip:remove')
AddEventHandler('esx_clip:remove', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	xPlayer.removeInventoryItem('magasin', 1)
end)

ESX.RegisterUsableItem('magasin', function(source)
	TriggerClientEvent('esx_clip:clipcli', source)
end)