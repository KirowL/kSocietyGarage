local function GetVehiclePrice(model)
    for jobName, jobData in pairs(Config.Garages) do 
        for _, vehicleData in pairs(jobData.Vehicles) do 
            if vehicleData.model == model then 
                return vehicleData.price
            end
        end
    end
end




RegisterNetEvent('kSocietyGarage:RequestOpenShopMenu')
AddEventHandler('kSocietyGarage:RequestOpenShopMenu', function()
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local zone = Config.Shop.ShopPosition.coords
    local radius = Config.Shop.ShopPosition.radius
    if IsPlayerInZone(_src, zone, radius) then
        if IsBoss(1, _src) and IsBoss(2, _src) then 
            TriggerClientEvent('kSocietyGarage:OpenShopMenu', _src, xPlayer.job.name, xPlayer.job2.name)
        elseif IsBoss(1, _src) then 
            TriggerClientEvent('kSocietyGarage:OpenShopMenu', _src, xPlayer.job.name, nil)
        elseif IsBoss(2, _src) then 
            TriggerClientEvent('kSocietyGarage:OpenShopMenu', _src, nil, xPlayer.job2.name)
        end
        TriggerClientEvent('kSocietyGarage:RefreshServerInteraction', _src)
    end
end)


ESX.RegisterServerCallback('kSocietyGarage:BuyVehicle', function(source, cb, vehicleModel, job)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local zone = Config.Shop.ShopPosition.coords
    local radius = Config.Shop.ShopPosition.radius
    if IsPlayerInZone(_src, zone, radius) and (IsBoss(1, _src) or IsBoss(2, _src)) then
        local price = GetVehiclePrice(vehicleModel)
        if price then 
            TriggerEvent('esx_addonaccount:getSharedAccount', "society_" .. job, function(account)
                if account.money >= price then 
                    account.removeMoney(price)
                    
                    cb(true)
                else  
                    cb(false)
                end
                TriggerClientEvent('kSocietyGarage:RefreshServerInteraction', _src)
            end)
        end
    end
end)

ESX.RegisterServerCallback('Aldalys:IsSocietyPlateTaken', function(source, cb, plate)
    local result = MySQL.Sync.fetchAll("SELECT plate FROM society_vehicles")
    if result ~= nil then 
        for k, v in pairs(result) do 
            if v == plate then cb(true) return end
        end 
    end
    cb(false)
end)