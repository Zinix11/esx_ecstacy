local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local PID           			= 0
local GUI           			= {}
local ecstasy_brickQTE    		= 0
ESX 			    			= nil
GUI.Time            			= 0
local ecstasy_pillQTE			= 0
local myJob 					= nil
local PlayerData 				= {}
local GUI 						= {}
local HasAlreadyEnteredMarker   = false
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

AddEventHandler('esx_ecstasy:hasEnteredMarker', function(zone)

    ESX.UI.Menu.CloseAll()

-- Ecstasy Zones
    if zone == 'EcstasyDelivery' then
        if myJob ~= "police" then
            CurrentAction     = 'ecstasy_collection'
            CurrentActionMsg  = _U('press_collect_ecstasy')
            CurrentActionData = {}
        end
    end

    if zone == 'EcstasyDelivery2' then
        if myJob ~= "police" then
            CurrentAction     = 'ecstasy_collection'
            CurrentActionMsg  = _U('press_collect_ecstasy')
            CurrentActionData = {}
        end
    end

    if zone == 'EcstasyTreatment' then
        if myJob ~= "police" then
            if ecstasy_brickQTE >= 1 then
                CurrentAction     = 'ecstasy_treatment'
                CurrentActionMsg  = _U('press_process_ecstasy')
                CurrentActionData = {}
            end
        end
    end

    if zone == 'EcstasyTreatment2' then
        if myJob ~= "police" then
            if ecstasy_brickQTE >= 1 then
                CurrentAction     = 'ecstasy_treatment'
                CurrentActionMsg  = _U('press_process_ecstasy')
                CurrentActionData = {}
            end
        end
    end

    if zone == 'EcstasyResell' then
        if myJob ~= "police" then
            if ecstasy_pillQTE >= 1 then
                CurrentAction     = 'ecstasy_resell'
                CurrentActionMsg  = _U('press_sell_ecstasy')
                CurrentActionData = {}
            end
        end
    end

    if zone == 'EcstasyResell2' then
        if myJob ~= "police" then
            if ecstasy_pillQTE >= 1 then
                CurrentAction     = 'ecstasy_resell'
                CurrentActionMsg  = _U('press_sell_ecstasy')
                CurrentActionData = {}
            end
        end
    end
end)

AddEventHandler('esx_ecstasy:hasExitedMarker', function(zone)

    CurrentAction = nil
    ESX.UI.Menu.CloseAll()

    TriggerServerEvent('esx_ecstasy:stopCollectionEcstasy')
    TriggerServerEvent('esx_ecstasy:stopTransformEcstasy')
    TriggerServerEvent('esx_ecstasy:stopSellEcstasy')
end)

-- Create Blips
Citizen.CreateThread(function()
    
    if myJob ~= "police" then -- Stops Police from seeing markers
	    for i=1, #Config.Map, 1 do
		
		    local blip = AddBlipForCoord(Config.Map[i].x, Config.Map[i].y, Config.Map[i].z)
		    SetBlipSprite (blip, Config.Map[i].id)
		    SetBlipDisplay(blip, 4)
            SetBlipColour (blip, Config.Map[i].color)
		    SetBlipScale  (blip, Config.Map[i].scale)
		    SetBlipAsShortRange(blip, true)

		    BeginTextCommandSetBlipName("STRING")
		    AddTextComponentString(Config.Map[i].name)
		    EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Render markers
Citizen.CreateThread(function()
    while true do

        Wait(0)

        local coords = GetEntityCoords(GetPlayerPed(-1))
        if myJob ~= "police" then -- Stops Police from seeing markers
            for k,v in pairs(Config.Zones) do
                if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.DrawDistance) then
                    DrawMarker(Config.MarkerType, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
                end
            end
        end
    end
end)

-- RETURN NUMBER OF ITEMS FROM SERVER
RegisterNetEvent('esx_ecstasy:ReturnInventory')
AddEventHandler('esx_ecstasy:ReturnInventory', function(ecstasybNbr, ecstasypNbr, jobName, currentZone)
	ecstasy_brickQTE    = ecstasybNbr
	ecstasy_pillQTE     = ecstasypNbr
	myJob               = jobName
	TriggerEvent('esx_ecstasy:hasEnteredMarker', currentZone)
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
    while true do

        Wait(0)

        local coords      = GetEntityCoords(GetPlayerPed(-1))
        local isInMarker  = false
        local currentZone = nil

        for k,v in pairs(Config.Zones) do
            if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < Config.ZoneSize.x / 2) then
                isInMarker  = true
                currentZone = k
            end
        end

        if isInMarker and not hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = true
            lastZone                = currentZone
            TriggerServerEvent('esx_ecstasy:GetUserInventory', currentZone)
        end

        if not isInMarker and hasAlreadyEnteredMarker then
            hasAlreadyEnteredMarker = false
            TriggerEvent('esx_ecstasy:hasExitedMarker', lastZone)
        end

    end
end)

-- Key Controls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustReleased(0, 38) then
                if CurrentAction == 'ecstasy_collection' then
                    TriggerServerEvent('esx_ecstasy:startCollectionEcstasy')
                end
                if CurrentAction == 'ecstasy_treatment' then
                    TriggerServerEvent('esx_ecstasy:startTransformEcstasy')
                end
                if CurrentAction == 'ecstasy_resell' then
                    TriggerServerEvent('esx_ecstasy:startSellEcstasy')
                end
                CurrentAction = nil
            end
        end
    end
end)





























































