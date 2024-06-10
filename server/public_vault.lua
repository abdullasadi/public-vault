local QBCore = exports[Config.Core]:GetCoreObject()
local VaultPrefix = "vault_"

QBCore.Functions.CreateCallback("kael-vault:server:checkowner", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local Owner = Player.PlayerData.citizenid
    local FindOwner = MySQL.query.await('SELECT * FROM `public_vault` WHERE v_owner = ?', { Owner })
    if FindOwner ~= nil and FindOwner[1] ~= nil then
        cb(true)
    else
        cb(false)
    end 
end)

QBCore.Functions.CreateCallback("kael-vault:server:checkkey", function(source, cb, owner, key)
    local Player = QBCore.Functions.GetPlayer(source)
    local FindKey = MySQL.query.await('SELECT * FROM `public_vault` WHERE v_owner = ? AND v_key = ?', { owner, key })
    if FindKey ~= nil and FindKey[1] ~= nil then
        cb(true)
    else
        cb(false)
    end 
end)

QBCore.Functions.CreateCallback("kael-vault:server:buynewaccess", function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    local Owner = Player.PlayerData.citizenid
    local Rand = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local Key = Owner .. Rand
    local PlayerMoney = Player.Functions.GetMoney("bank")
    if PlayerMoney >= price then
        Player.Functions.RemoveMoney("bank", price)
        MySQL.query.await("INSERT INTO `public_vault` (`v_owner`, `v_key`) VALUES (?, ?)", { Owner, Key })
        local info = {owner = Owner, key = Key}
        Player.Functions.AddItem("vault_keycard", 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["vault_keycard"], "add")
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback("kael-vault:server:buynewkey", function(source, cb, price)
    local Player = QBCore.Functions.GetPlayer(source)
    local Owner = Player.PlayerData.citizenid
    local Rand = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(2)
    local Key = Owner .. Rand
    local PlayerMoney = Player.Functions.GetMoney("bank")
    if PlayerMoney >= price then
        Player.Functions.RemoveMoney("bank", price)
        MySQL.query.await("UPDATE `public_vault` SET `v_key` = ? WHERE `v_owner` = ?", { Key, Owner })
        local info = {owner = Owner, key = Key}
        Player.Functions.AddItem("vault_keycard", 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["vault_keycard"], "add")
        cb(true)
    else
        cb(false)
    end
end)


QBCore.Functions.CreateCallback("kael-vault:server:accessvault", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local CardsData = {}
    for slot, data in pairs(Player.PlayerData.items) do
        if data ~= nil then
            if data.name == 'vault_keycard' then
                local FindCard = MySQL.query.await('SELECT * FROM `public_vault` WHERE v_owner = ?', { data.info.owner })
                if FindCard ~= nil and FindCard[1] ~= nil then                    
                    CardsData[data.info.owner] = {
                        owner = data.info.owner,
                        key = data.info.key,
                    }
                end                
            end
        end
    end
    if next(CardsData) then 
        cb(CardsData)
    else
        cb(false)
    end
end)

