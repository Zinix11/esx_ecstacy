ESX 						   		= nil
local CopsConnected      			= 0
local PlayersHarvestingEcstasy     	= {}
local PlayersTransformingEcstasy   	= {}
local PlayersSellingEcstasy        	= {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function CountCops()

	local xPlayers = ESX.GetPlayers()

	CopsConnected = 0

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		if xPlayer.job.name == 'police' then
			CopsConnected = CopsConnected + 1
		end
	end

	SetTimeout(5000, CountCops)

end

CountCops()

-- Ecstasy Stage 1

local function HarvestEcstasy(source)

	if CopsConnected < Config.RequiredCopsEcstasy then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsEcstasy)
		return
	end

	SetTimeout(5000, function()

		if PlayersHarvestingEcstasy[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local ecstasy = xPlayer.getInventoryItem('ecstasy_brick')

			local money = xPlayer.getMoney()

			if ecstasy.limit ~= -1 and ecstasy.count >= ecstasy.limit then
				TriggerClientEvent('esx:showNotification', source, _U('inv_full_ecstasy'))
			elseif money < 1000 then
					TriggerClientEvent('esx:showNotification', source, _U('need_more_money'))
            else
                xPlayer.removeMoney(1000)
				xPlayer.addInventoryItem('ecstasy_brick', 1)
				HarvestEcstasy(source)
			end

		end
	end)
end

RegisterServerEvent('esx_ecstasy:startCollectionEcstasy')
AddEventHandler('esx_ecstasy:startCollectionEcstasy', function()

	local _source = source

	PlayersHarvestingEcstasy[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('pickup_in_prog'))

	HarvestEcstasy(_source)

end)

RegisterServerEvent('esx_ecstasy:stopCollectionEcstasy')
AddEventHandler('esx_ecstasy:stopCollectionEcstasy', function()

	local _source = source

	PlayersHarvestingEcstasy[_source] = false

end)

-- Stage 2

local function TransformEcstasy(source)

	if CopsConnected < Config.RequiredCopsEcstasy then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsEcstasy)
		return
	end

	SetTimeout(10000, function()

		if PlayersTransformingEcstasy[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local brickQuantity = xPlayer.getInventoryItem('ecstasy_brick').count
			local pillQuantity = xPlayer.getInventoryItem('ecstasy_pills').count

			if ecstasy_pillQTE > 350 then
				TriggerClientEvent('esx:showNotification', source, _U('too_many_pills'))
			elseif ecstasy_brickQTE < 1 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_bricks'))
			else
				xPlayer.removeInventoryItem('ecstasy_brick', 1)
				xPlayer.addInventoryItem('ecstasy_pills', 10)
			
				TransformEcstasy(source)
			end

		end
	end)
end

RegisterServerEvent('esx_ecstasy:startTransformEcstasy')
AddEventHandler('esx_ecstasy:startTransformEcstasy', function()

	local _source = source

	PlayersTransformingEcstasy[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('packing_in_prog'))

	TransformEcstasy(_source)

end)

RegisterServerEvent('esx_ecstasy:stopTransformEcstasy')
AddEventHandler('esx_ecstasy:stopTransformEcstasy', function()

	local _source = source

	PlayersTransformingEcstasy[_source] = false

end)

-- Stage 3

local function SellEcstasy(source)

	if CopsConnected < Config.RequiredCopsEcstasy then
		TriggerClientEvent('esx:showNotification', source, _U('act_imp_police') .. CopsConnected .. '/' .. Config.RequiredCopsEcstasy)
		return
	end

	SetTimeout(7500, function()

		if PlayersSellingEcstasy[source] == true then

			local xPlayer  = ESX.GetPlayerFromId(source)

			local pillQuantity = xPlayer.getInventoryItem('ecstasy_pills').count

			if pillQuantity == 0 then
				TriggerClientEvent('esx:showNotification', source, _U('no_pills_sale'))
			else
				xPlayer.removeInventoryItem('ecstasy_pills', 1)
				if CopsConnected == 0 then
                    xPlayer.addAccountMoney('black_money', 100)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_pill'))
                elseif CopsConnected == 1 then
                    xPlayer.addAccountMoney('black_money', 120)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_pill'))
                elseif CopsConnected == 2 then
                    xPlayer.addAccountMoney('black_money', 140)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_pill'))
                elseif CopsConnected == 3 then
                    xPlayer.addAccountMoney('black_money', 160)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_pill'))
                elseif CopsConnected == 4 then
                    xPlayer.addAccountMoney('black_money', 180)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_pill'))
                elseif CopsConnected >= 5 then
                    xPlayer.addAccountMoney('black_money', 200)
                    TriggerClientEvent('esx:showNotification', source, _U('sold_one_pill'))
                end
				
				SellEcstasy(source)
			end

		end
	end)
end

RegisterServerEvent('esx_ecstasy:startSellEcstasy')
AddEventHandler('esx_ecstasy:startSellEcstasy', function()

	local _source = source

	PlayersSellingEcstasy[_source] = true

	TriggerClientEvent('esx:showNotification', _source, _U('sale_in_prog'))

	SellEcstasy(_source)

end)

RegisterServerEvent('esx_ecstasy:stopSellEcstasy')
AddEventHandler('esx_ecstasy:stopSellEcstasy', function()

	local _source = source

	PlayersSellingEcstasy[_source] = false

end)

-- RETURN INVENTORY TO CLIENT
RegisterServerEvent('esx_ecstasy:GetUserInventory')
AddEventHandler('esx_ecstasy:GetUserInventory', function(currentZone)
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
    TriggerClientEvent('esx_ecstasy:ReturnInventory', 
    	_source,
		xPlayer.getInventoryItem('ecstasy_brick').count, 
		xPlayer.getInventoryItem('ecstasy_pills').count,
		xPlayer.job.name, 
		currentZone
    )
end)
