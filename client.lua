local isTackling = false
local isGettingTackled = false
local lastTackleTime = 0
local isRagdoll = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isRagdoll then
			SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
		end
	end
end)

RegisterNetEvent('ItsMatOG:getTackled')
AddEventHandler('ItsMatOG:getTackled', function(target)
	isGettingTackled = true
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	SetPedToRagdoll(playerPed, math.random(3500, 7500), math.random(3500, 7500), 0, 0, 0, 0) 
	Citizen.Wait(3000)
	isRagdoll = false
	isGettingTackled = false
end)

RegisterNetEvent('ItsMatOG:playTackle')
AddEventHandler('ItsMatOG:playTackle', function()
	local playerPed = GetPlayerPed(-1)
	RequestAnimDict("swimming@first_person@diving")
	while not HasAnimDictLoaded("swimming@first_person@diving") do
		Citizen.Wait(10)
	end
	TaskPlayAnim(playerPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
	Wait(500)
	ClearPedSecondaryTask(playerPed)
	SetPedToRagdoll(playerPed, math.random(2500, 5500), math.random(2500, 5500), 0, 0, 0, 0) 
	Wait(3000)
	isTackling = false
end)

RegisterNetEvent('ItsMatOG:getPushed')
AddEventHandler('ItsMatOG:getPushed', function(target)
	isGettingTackled = true
	local playerPed = GetPlayerPed(-1)
	local targetPed = GetPlayerPed(GetPlayerFromServerId(target))
	SetPedToRagdoll(playerPed, math.random(2000, 5500), math.random(2000, 5500), 0, 0, 0, 0) 
	Citizen.Wait(3000)
	isRagdoll = false
	isGettingTackled = false
end)

RegisterNetEvent('ItsMatOG:playPush')
AddEventHandler('ItsMatOG:playPush', function()
	local playerPed = GetPlayerPed(-1)
	RequestAnimDict("swimming@first_person@diving")
	while not HasAnimDictLoaded("swimming@first_person@diving") do
		Citizen.Wait(10)
	end
	TaskPlayAnim(playerPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
	Wait(500)
	ClearPedSecondaryTask(playerPed)
	SetPedToRagdoll(playerPed, 250, 250, 0, 0, 0, 0) 
	Wait(500)
	isTackling = false
end)

function GetClosestPlayer()
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if target ~= ply then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = GetPlayerPed(-1)
		running = IsPedRunning(playerPed) or IsPedSprinting(playerPed)
		if IsControlPressed(0, 21) and IsControlPressed(0, 47) and not isTackling then
			local closestPlayer, distance = GetClosestPlayer();
			if distance ~= -1 and distance <= 1.5 and not isTackling and not isGettingTackled and not IsPedInAnyVehicle(GetPlayerPed(-1)) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
				isTackling = true
				lastTackleTime = GetGameTimer()
				if running then
					TriggerServerEvent('ItsMatOG:tryTackle', GetPlayerServerId(closestPlayer))
				else
					TriggerServerEvent('ItsMatOG:tryPush', GetPlayerServerId(closestPlayer))
				end
			end
		end
	end
end, false)

RegisterCommand("tackle", function(source)
	local playerPed = GetPlayerPed(-1)
	running = IsPedRunning(playerPed) or IsPedSprinting(playerPed)
	if not isTackling then
		local closestPlayer, distance = GetClosestPlayer();
		if distance ~= -1 and distance <= 1.5 and not isTackling and not isGettingTackled and not IsPedInAnyVehicle(GetPlayerPed(-1)) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
			isTackling = true
			lastTackleTime = GetGameTimer()
			if running then
				TriggerServerEvent('ItsMatOG:tryTackle', GetPlayerServerId(closestPlayer))
			else
				TriggerServerEvent('ItsMatOG:tryPush', GetPlayerServerId(closestPlayer))
			end
		end
	end
end, false)
TriggerEvent("chat:addSuggestion", "/tackle", "Tackle the nearest person.")
RegisterKeyMapping("tackle", "Tackle the nearest person", "keyboard", "")