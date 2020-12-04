ESX = nil

local PlayerData              = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
end)



Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
  end
end)



Citizen.CreateThread(function() 
    ped = GetHashKey(Config.DealerPed)
    RequestModel(ped)
    while not HasModelLoaded(ped) do
        Wait(1)
    end
    if Config.EnablePeds then
        for _, dealer in pairs(Config.Location) do
            local npc = CreatePed(1, ped, dealer.x, dealer.y, dealer.z-1.0, dealer.heading, false, true)

            SetEntityHeading(npc, dealer.heading)
            FreezeEntityPosition(npc, true)
            SetEntityInvincible(npc, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
        end
    end
end)

local menuOpen = false
local wasOpen = false


Citizen.CreateThread(function()
    while true do
        local sleep = 5000
        local _source = source
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        for i = 1, #Config.Location, 1 do 
            local konum = Config.Location[i]
            local userDst = GetDistanceBetweenCoords(pedCoords, konum.x, konum.y, konum.z, true)
            if userDst <= 15 then
                sleep = 2
                if (userDst <= 5) then
                    if Config.DrawText then
                        DrawText3D(konum.x, konum.y, konum.z, 'Satıcı ile konusmak için [E] Tusuna bas')
                    end
                    if userDst <= 1.0 then
                        if Config.DrawText then
                            
                        else
                            ESX.ShowHelpNotification('Satıcı ile konusmak için [E] Tusuna bas')
                        end
                        if IsControlJustPressed(0, 38) then
                            wasOpen = true
                            OpenDealer()
                        end
                    else
                        if wasOpen  then
							wasOpen = false
							ESX.UI.Menu.CloseAll()
                        end
                        Citizen.Wait(500)
                    end
                end
            end
        end 
        Citizen.Wait(sleep)
    end
end)

function OpenDealer() 
    ESX.UI.Menu.CloseAll()
    local elements = {}
    menuOpen = true
    for k, v in pairs(ESX.GetPlayerData().inventory) do
        local price = Config.DealerItems[v.name]
        print(v.count)
        if v.count == 0 then
            table.insert(elements, {
                label = ('Satacak bir şeyin yok.')
            })
        else
            if price and v.count > 0 then
                table.insert(elements, {
                    label = ('%s - <span style="color:green;">%s</span>'):format(v.label, '$'..ESX.Math.GroupDigits(price)),
                    name = v.name,
                    price = price,
    
                    type = 'slider',
                    value = 1,
                    min = 1,
                    max = v.count
                })
            end
        end
        
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dealer_shop', {
        title = 'Satıcı',
        align = 'left',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('ali-selling:sellItem', data.current.name, data.current.value)
    end, function(data, menu)
        menu.close()
        menuOpen = false
    end)
end

function DrawText3D(x,y,z,text,size)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)

    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
