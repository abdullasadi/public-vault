local QBCore = exports[Config.Core]:GetCoreObject()
local VaultPrefix = "vault_"
local Price = 50000
local KeyPrice = 5000


local PublicVault = {
    {
        name = "Public Vault 1",
        coords = vector3(1577.63, -1685.84, 88.16),
        length = 1.5,
        width = 0.5,
        heading = 15,
        minZ = 85.96,
        maxZ = 89.96,
    },
    {
        name = "Public Vault 2",
        coords = vector3(1632.88, 3719.69, 34.56),
        length = 1.5,
        width = 0.5,
        heading = 35,
        minZ = 32.56,
        maxZ = 36.56,
    },
    {
        name = "Public Vault 3",
        coords = vector3(96.43, 6362.44, 31.38),
        length = 1.5,
        width = 1.5,
        heading = 295,
        minZ = 28.58,
        maxZ = 32.58,
    },
}

CreateThread(function()
    for k, v in pairs(PublicVault) do 
        exports[Config.Target]:AddBoxZone("pubvault".. k, v.coords, v.length, v.width, {
            name = "pubvault".. k,
            debugPoly = false,
            heading = v.heading,
            minZ = v.minZ,
            maxZ = v.maxZ,
        }, {
            options = {
                {  
                    event = "kael-vault:client:accessvault",
                    icon = "fas fa-vault",
                    label = "Access Vault",
                },
            },
            distance = 1.5
        })

        local VaultBlip = AddBlipForCoord(v.coords)
        SetBlipSprite(VaultBlip, 730)
        SetBlipColour(VaultBlip, 36)
        SetBlipAsShortRange(VaultBlip, true)
        SetBlipDisplay(VaultBlip, 4)
        SetBlipScale(VaultBlip, 0.8)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Public Vault")
        EndTextCommandSetBlipName(VaultBlip)
    end
end)

RegisterNetEvent("kael-vault:client:accessvault", function()
    QBCore.Functions.TriggerCallback("kael-vault:server:checkowner", function(Owner)
        if Owner then 
            local VaultMenu = {
                {
                    header = 'Public Vault',
                    icon = 'fas fa-vault',
                    txt = "",
                    isMenuHeader = true,
                },
                {
                    header = "Access Vault",
                    icon = "fas fa-door-open",
                    txt = "Access Vault With Key",
                    params = {
                        event = 'kael-vault:client:accessvaultwithkey',
                    }
                },
                {
                    header = "Request New Key",
                    icon = "fas fa-key",
                    txt = "Get New Access Card",
                    params = {
                        event = 'kael-vault:client:buynewkey',
                    }
                },
            }
            exports[Config.Menu]:openMenu(VaultMenu)
        else
            local VaultMenu = {
                {
                    header = 'Public Vault',
                    icon = 'fas fa-vault',
                    txt = "",
                    isMenuHeader = true,
                },
                {
                    header = "Access Vault",
                    icon = "fas fa-door-open",
                    txt = "Access Vault With Keys",
                    params = {
                        event = 'kael-vault:client:accessvaultwithkey',
                    }
                },
                {
                    header = "Buy Vault Access",
                    icon = "fas fa-id-card-clip",
                    txt = "Lifetime Membership: $50000",
                    params = {
                        event = 'kael-vault:client:buyaccess',
                    }
                },
            }
            exports[Config.Menu]:openMenu(VaultMenu)
        end
    end)
end)

RegisterNetEvent("kael-vault:client:accessvaultwithkey", function()
    QBCore.Functions.TriggerCallback("kael-vault:server:accessvault", function(KEY)
        if KEY then 
            TriggerEvent("kael-vault:client:accessmenu", KEY)
        else
            QBCore.Functions.Notify("You don't have any valid key cards!", "error")
        end
    end, Price)
end)

RegisterNetEvent("kael-vault:client:buyaccess", function()
    QBCore.Functions.TriggerCallback("kael-vault:server:buynewaccess", function(CB)
        if CB then 
            TriggerEvent("kael-vault:client:accessvault")
        else
            QBCore.Functions.Notify("You don't have enough money!", "bank")
        end
    end, Price)
end)

RegisterNetEvent("kael-vault:client:accessmenu", function(data)
    local VaultMenu = {
        {
            header = 'Public Vault',
            icon = 'fas fa-vault',
            txt = "",
            isMenuHeader = true,
        },        
    }
    for k, v in pairs(data) do
        VaultMenu[#VaultMenu + 1] = {
            header = "Open " .. k,
            icon = "fas fa-id-card-clip",
            txt = "Key: " .. v.key,
            params = {
                event = 'kael-vault:client:openvault',
                args = {
                    owner = v.owner,
                    key = v.key,
                }
            }
        }
    end
    exports[Config.Menu]:openMenu(VaultMenu)
end)

RegisterNetEvent("kael-vault:client:openvault", function(data)
    local Owner = data.owner
    local Key = data.key
    local Vault = VaultPrefix .. Owner .. "Stash"
    QBCore.Functions.TriggerCallback("kael-vault:server:checkkey", function(KEY)
        if KEY then             
            TriggerServerEvent("inventory:server:OpenInventory", "stash", Vault, {
                maxweight = 1000000,
                slots = 100,
            })
            TriggerEvent("inventory:client:SetCurrentStash", Vault)
        else
            QBCore.Functions.Notify("This is not a valid keycard!", "error")  
        end
    end, Owner, Key)
end)

RegisterNetEvent("kael-vault:client:buynewkey", function(data)   
    QBCore.Functions.TriggerCallback("kael-vault:server:buynewkey", function(KEY)
        if KEY then             
            TriggerEvent("kael-vault:client:accessvault")
        else
            QBCore.Functions.Notify("You don't have enough money!", "bank")
        end
    end, KeyPrice)
end)


