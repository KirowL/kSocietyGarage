ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
	  TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	  Citizen.Wait(1)
    end

    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)


serverInteraction = false

RegisterNetEvent('kSocietyGarage:RefreshServerInteraction')
AddEventHandler('kSocietyGarage:RefreshServerInteraction', function()
    serverInteraction = false
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)
    ESX.PlayerData.job2 = job2
end)

local NumberCharset = {}
for i = 48,  57 do table.insert(NumberCharset, string.char(i)) end

function GetRandomNumber(length)
	math.randomseed(GetGameTimer())
	if length > 0 then
		return GetRandomNumber(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
	else
		return ''
	end
end

function GenerateSocietyVehiclePlate(job)
    local generatedPlate
	local doBreak = false

	while true do
		Citizen.Wait(2)
		math.randomseed(GetGameTimer())
		generatedPlate = string.upper(Config.GenericJobPlate[job] .. GetRandomNumber(4))

		ESX.TriggerServerCallback('Aldalys:IsSocietyPlateTaken', function(isPlateTaken)
			if not isPlateTaken then
				doBreak = true
			end
		end, generatedPlate)

		if doBreak then
			break
		end
	end

	return generatedPlate
end