ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function IsPlayerInZone(playerId, zone, radius)
    local player = GetPlayerPed(playerId)
    local playerPos = GetEntityCoords(player)
    local distance = #(playerPos - zone)
    if distance <= radius then
        return true
    end
    return false
end

function IsJobValid(playerId, jobName)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    return (xPlayer.job.name == jobName) or (xPlayer.job2.name == jobName)
end

function IsBoss(jobId, playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if jobId == 1 then 
        return xPlayer.job.grade_name == 'boss'
    elseif jobId == 2 then
        return xPlayer.job2.grade_name == 'boss'
    end
end

function GetPlayersFromJob(jobName)
    local players = {}
    for k, v in pairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if (xPlayer.job.name == jobName) or (xPlayer.job2.name) then
            table.insert(players, v)
        end
    end
    return players
end

function UpdateDataForJob(job)
    local players = GetPlayersFromJob(job)
    local data = MySQL.query("SELECT * FROM society_vehicles WHERE job = ?", {job})
    if data ~= nil and data[1] ~= nil then 
        for k, v in pairs(players) do
            TriggerClientEvent('kSocietyGarage:UpdateGarageData', v, data)
        end
    end
end

RegisterNetEvent('kSocietyGarage:RequestOpenMenu')
AddEventHandler('kSocietyGarage:RequestOpenMenu', function(jobName)
    local _src = source
    local zone = Config.Garages[jobName].GaragePosition.coords
    local radius = Config.Garages[jobName].GaragePosition.radius
    if IsPlayerInZone(_src, zone, radius) and IsJobValid(_src, jobName) then 
        local data = MySQL.query.await("SELECT * FROM society_vehicles WHERE job = ?", {jobName})
        TriggerClientEvent('kSocietyGarage:OpenMenu', _src, data)
        TriggerClientEvent('kSocietyGarage:RefreshServerInteraction', _src)
    end
end)



RegisterNetEvent('kSocietyGarage:AddVehicleToSocietyGarage')
AddEventHandler('kSocietyGarage:AddVehicleToSocietyGarage', function(job, vehicleProperties)
    local _src = source
    local zone = Config.Shop.ShopPosition.coords
    local radius = Config.Shop.ShopPosition.radius
    if IsPlayerInZone(_src, zone, radius) and IsJobValid(_src, job) then 
        MySQL.query.await("INSERT INTO society_vehicles (job, plate, vehicle, is_stored) VALUES (?, ?, ?, ?)", {job, vehicleProperties.plate, json.encode(vehicleProperties), 0})
        TriggerClientEvent('kSocietyGarage:RefreshServerInteraction', _src)
        UpdateDataForJob(job)
    end
end)

RegisterNetEvent('kSocietyGarage:StoreVehicle')
AddEventHandler('kSocietyGarage:StoreVehicle', function(job, properties)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.query("SELECT job FROM society_vehicles WHERE plate = ?", {properties.plate}, function(result)
        if result[1].job ~= nil and xPlayer.job.name == result[1].job then 
            MySQL.query.await("UPDATE society_vehicles SET is_stored = 1, vehicle = ? WHERE plate = ?", {json.encode(properties), properties.plate})
            TriggerClientEvent('kSocietyGarage:RefreshServerInteraction', _src)
            UpdateDataForJob(job)
        end
    end)
end)

ESX.RegisterServerCallback('kSocietyGarage:SetVehicleOut', function(source, cb, job, properties)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    MySQL.query("SELECT job FROM society_vehicles WHERE plate = ?", {properties.plate}, function(result)
        if result[1].job ~= nil and xPlayer.job.name == result[1].job then 
            MySQL.query.await("UPDATE society_vehicles SET is_stored = 0 WHERE plate = ?", {properties.plate})
            TriggerClientEvent('kSocietyGarage:RefreshServerInteraction', _src)
            UpdateDataForJob(job)
            cb(true)
        else 
            cb(false)
        end
    end)
end)    

MySQL.ready(function()
    if Config.StoreVehiclesOnReboot then 
        MySQL.update("UPDATE society_vehicles SET is_stored = 1")
    end
end)

























ESX.RegisterJob('police', 'LSPD', {
    ['0'] = {
        grade = 0,
        name = 'seller',
        label = 'Vendeur',
        salary = 150
    },
    ['1'] = {
        grade = 1,
        name = 'associate',
        label = 'Associé',
        salary = 200
    }, 
    ['2'] = {
        grade = 2,
        name = 'codirector',
        label = 'Co-directeur',
        salary = 250
    }, 
    ['3'] = {
        grade = 3,
        name = 'boss',
        label = 'Directeur',
        salary = 30
    }, 
})


ESX.RegisterJob('ambulance', 'Ambulance', {
    ['0'] = {
        grade = 0,
        name = 'seller',
        label = 'Vendeur',
        salary = 150
    },
    ['1'] = {
        grade = 1,
        name = 'associate',
        label = 'Associé',
        salary = 200
    }, 
    ['2'] = {
        grade = 2,
        name = 'codirector',
        label = 'Co-directeur',
        salary = 250
    }, 
    ['3'] = {
        grade = 3,
        name = 'boss',
        label = 'Directeur',
        salary = 30
    }, 
})

