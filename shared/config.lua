local ESX, QBCore = nil
local xPlayer = nil
local identifier = nil


if Config.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
else
    QBCore = exports['qb-core']:GetCoreObject()
end

lib.locale()

lib.callback.register('gary_garage:server:checkOwner', function(source, plate)
    local plate = string.gsub(plate, ' ', '')

    if Config.Framework == "esx" then
        result = CustomSQL('query', 'SELECT owner FROM owned_vehicles WHERE REPLACE(plate, " ", "") = ?', {plate})
        if #result > 0 then
            return result[1].owner
        end
    else
        result = CustomSQL('query', 'SELECT citizenid FROM player_vehicles WHERE REPLACE(plate, " ", "") = ?', {plate})
        if #result > 0 then
            return result[1].citizenid
        end
    end
end)

lib.callback.register('gary_garage:server:getVehicles', function(source, job, type)
    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(source)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(source)
        identifier = xPlayer.PlayerData.citizenid
    end

    local result

    if job then
        if Config.Framework == "esx" then
            result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE owner = ? AND job = ? AND type = ? ORDER BY stored DESC',
                {identifier, job, type})
        else
            result = CustomSQL('query', 'SELECT * FROM player_vehicles WHERE citizenid = ? AND job = ? AND type = ? ORDER BY state DESC',
                {identifier, job, type})
        end
    else
        if Config.Framework == "esx" then
            result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE owner = ? AND type = ? ORDER BY stored DESC', {identifier, type})
        else
            result = CustomSQL('query', 'SELECT * FROM player_vehicles WHERE citizenid = ? AND type = ? ORDER BY state DESC', {identifier, type})
        end
    end


    return result
end)

lib.callback.register('gary_garage:server:getImpoundedVehicles', function(source, type)
    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(source)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(source)
        identifier = xPlayer.PlayerData.citizenid
    end

    if Config.Framework == "esx" then
        result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE owner = ? and impound = 1 and type = ?', {identifier, type})
    else
        result = CustomSQL('query', 'SELECT * FROM player_vehicles WHERE citizenid = ? and impound = 1 and type = ?', {identifier, type})
    end
    return result
end)

lib.callback.register('gary_garage:server:canPay', function(source, amount)
    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(source)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(source)
        identifier = xPlayer.PlayerData.citizenid
    end

    if Config.ImpoundTakeMoneyType == "bank" then
        PlayerMoney = xPlayer.PlayerData.money.bank -- Get the Current Player`s Balance.
        MoneyType = "bank"
    else
        PlayerMoney = xPlayer.PlayerData.money.cash -- Get the Current Player`s Balance.
        MoneyType = "cash"
    end

    if PlayerMoney >= amount then -- check if the Player`s Money is more or equal to the cost.
        xPlayer.Functions.RemoveMoney(MoneyType ,amount) -- remove Cost from balance
        return true
    else
        return false
    end
    
end)

lib.callback.register('gary_garage:server:getVehicle', function(source, plate)
    local plate = string.gsub(plate, ' ', '')

    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(source)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(source)
        identifier = xPlayer.PlayerData.citizenid
    end

    if Config.Framework == "esx" then
        result = CustomSQL('query', 'SELECT * FROM owned_vehicles WHERE REPLACE(plate, " ", "") = ? and owner = ?', {plate, identifier})
    else
        result = CustomSQL('query', 'SELECT * FROM player_vehicles WHERE REPLACE(plate, " ", "") = ? and citizenid = ?', {plate, identifier})

    end

    return result[1]
end)

RegisterServerEvent('gary_garage:server:updateVehicle', function(plate, vehicle, parking, stored, type)
    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(source)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(source)
        identifier = xPlayer.PlayerData.citizenid
    end

    if Config.Framework == "esx" then
        CustomSQL('update', 'UPDATE owned_vehicles SET vehicle = ?, parking = ?, stored = ?, impound = 0 WHERE REPLACE(plate, " ", "") = ? and owner = ?', {vehicle, parking, stored, plate, identifier})
    else
        CustomSQL('update', 'UPDATE player_vehicles SET mods = ?,type = ?, garage = ?, state = ?, impound = 0 WHERE REPLACE(plate, " ", "") = ? and citizenid = ?', 
        {vehicle, type ,parking , stored , plate, identifier})

    end 
end)

RegisterServerEvent('gary_garage:server:buyVehicle', function(plate, vehicle, parking, job, type)
    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(source)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(source)
        identifier = xPlayer.PlayerData.citizenid
    end

    if Config.Framework == "esx" then
        CustomSQL('insert',
            'INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, parking, impound, job) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {identifier, plate, json.encode(vehicle), 'car', 1, parking, 0, job})
    else
        CustomSQL('insert',
            'INSERT INTO player_vehicles (license, citizenid, vehicle, hash ,mods ,plate, type, state, garage, impound, job) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            {xPlayer.PlayerData.license, xPlayer.PlayerData.citizenid, vehicle.model, GetHashKey(vehicle.model), json.encode(vehicle), plate, type, 1, parking, 0, job})
    end
end)

RegisterServerEvent('gary_garage:server:setVehicleOut', function(plate)
    local src = source
    local xPlayer, identifier

    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(src)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(src)
        identifier = xPlayer.PlayerData.citizenid
    end

    if xPlayer and identifier then
        if Config.Framework == "esx" then
            CustomSQL('update',
                'UPDATE owned_vehicles SET stored = 0, parking = NULL, impound = 0 WHERE REPLACE(plate, " ", "") = ? and owner = ?',
                {plate, identifier})
        else
            CustomSQL('update',
                'UPDATE player_vehicles SET state = 0, garage = NULL, impound = 0 WHERE REPLACE(plate, " ", "") = ? and citizenid = ?',
                {plate, identifier})
        end

        local playerName = GetPlayerName(src)
        local playerLicense = xPlayer.PlayerData.license

        if playerName and playerLicense then
            discordLog(
                playerName .. ' - ' .. playerLicense .. ' - ' .. identifier,
                playerName .. ' - ' .. playerLicense .. ' - ' .. identifier .. ' took their car out of the garage. Plate: ' .. plate,
                Config.Webhook['setVehicleOut']
            )
        else
            print("Error: Could not retrieve player name or license.")
        end
    else
        print("Error: Could not retrieve player information.")
    end
end)

RegisterServerEvent('gary_garage:server:setVehicleParking', function(plate, parking)
    local src = source
    local xPlayer, identifier

    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(src)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(src)
        identifier = xPlayer.PlayerData.citizenid
    end

    if xPlayer and identifier then
        if Config.Framework == "esx" then
            CustomSQL('update', 'UPDATE owned_vehicles SET stored = 1, parking = ?, impound = 0 WHERE plate = ? and owner = ?',
                {parking, plate, identifier})
        else
            CustomSQL('update', 'UPDATE player_vehicles SET state = 1, garage = ?, impound = 0 WHERE plate = ? and citizenid = ?',
                {parking, plate, identifier})
        end

        local playerName = GetPlayerName(src)
        local playerLicense = xPlayer.PlayerData.license

        if playerName and playerLicense then
            discordLog(
                playerName .. ' - ' .. playerLicense .. ' - ' .. identifier,
                playerName .. ' - ' .. playerLicense .. ' - ' .. identifier .. ' parked their car. Plate: ' .. plate,
                Config.Webhook['setVehicleParking']
            )
        else
            print("Error: Could not retrieve player name or license.")
        end
    else
        print("Error: Could not retrieve player information.")
    end
end)

RegisterServerEvent('gary_garage:server:setVehicleImpound', function(plate, impound)
    local src = source
    local xPlayer, identifier

    if Config.Framework == "esx" then
        xPlayer = ESX.GetPlayerFromId(src)
        identifier = xPlayer.getIdentifier()
    else
        xPlayer = QBCore.Functions.GetPlayer(src)
        identifier = xPlayer.PlayerData.citizenid
    end

    if xPlayer and identifier then
        if Config.Framework == "esx" then
            CustomSQL('update', 'UPDATE owned_vehicles SET parking = NULL, stored = 0, impound = ? WHERE plate = ? and owner = ?',
                {impound, plate, identifier})
        else
            CustomSQL('update', 'UPDATE player_vehicles SET garage = NULL, state = 0, impound = ? WHERE plate = ? and citizenid = ?',
                {impound, plate, identifier})
        end

        local playerName = GetPlayerName(src)
        local playerLicense = xPlayer.PlayerData.license

        if playerName and playerLicense then
            discordLog(
                playerName .. ' - ' .. playerLicense .. ' - ' .. identifier,
                playerName .. ' - ' .. playerLicense .. ' - ' .. identifier .. ' moved their car to the impound. Plate: ' .. plate,
                Config.Webhook['setVehicleImpound']
            )
        else
            print("Error: Could not retrieve player name or license.")
        end
    else
        print("Error: Could not retrieve player information.")
    end
end)

lib.callback.register('gary_garage:setPlayerRoutingBucket', function(source, bucket)
    if not bucket then
        bucket = math.random(1000)
    end

    SetPlayerRoutingBucket(source, bucket)
    return true
end)

if Config.ImpoundCommandEnabled then
    if Config.Framework == "esx" then
        ESX.RegisterCommand(Config.ImpoundCommand.command, 'user', function(xPlayer, args, showError)
            for k, job in pairs(Config.ImpoundCommand.jobs) do
                if xPlayer.getJob().name == job then
                    xPlayer.triggerEvent('gary_garage:impoundVehicle')
                end
            end
        end, false, {
            help = locale('command_impound')
        })
    else
        RegisterCommand(Config.ImpoundCommand.command, function(source, args)
            local xPlayer = QBCore.Functions.GetPlayer(source)
        
            for _, job in pairs(Config.ImpoundCommand.jobs) do
                if xPlayer.PlayerData.job.name == job then
                    TriggerClientEvent('gary_garage:impoundVehicle', source)
                    return
                end
            end
            TriggerClientEvent('gary_garage:notification', locale('command_impound'), 5500, "success")
        end)
    end
end

function CustomSQL(type, action, placeholder)
    local result = nil
    if Config.MySQL == 'oxmysql' then
        if type == 'query' then
            result = exports.oxmysql:query_async(action, placeholder)
        elseif type == 'update' then
            result = exports.oxmysql:update(action, placeholder)
        elseif type == 'insert' then
            result = exports.oxmysql:insert(action, placeholder)
        end
    elseif Config.MySQL == 'mysql-async' then
        if type == 'query' then
            result = MySQL.Sync.query(action, placeholder)
        elseif type == 'update' then
            result = MySQL.Async.execute(action, placeholder)
        elseif type == 'insert' then
            result = MySQL.Async.insert(action, placeholder)
        end
    elseif Config.MySQL == 'ghmattisql' then
        if type == 'query' then
            result = exports.ghmattimysql:executeSync(action, placeholder)
        elseif type == 'update' then
            result = exports.ghmattimysql:execute(action, placeholder)
        elseif type == 'insert' then
            result = exports.ghmattimysql:execute(action, placeholder)
        end
    end
    return result
end

function discordLog(name, message, webhookURL)
    if webhookURL and webhookURL ~= "" then
        local data = {
            {
                ["color"] = 3553600,
                ["title"] = "**Gary's Garage**",
                ["description"] = message,
            }
        }
        PerformHttpRequest(webhookURL, function(err, text, headers)
        end, 'POST', json.encode({username = "Gary's Garage", embeds = data}), { ['Content-Type'] = 'application/json' })
    else
        print("Invalid webhook URL: "..tostring(webhookURL))
    end
end