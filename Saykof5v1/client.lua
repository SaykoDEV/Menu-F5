ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--------- Menu -------

local Xperso = {
    ItemSelected = {},
    ItemSelected2 = {},
}

function CheckQuantity(number)
    number = tonumber(number)

    if type(number) == 'number' then
        number = ESX.Math.Round(number)

        if number > 0 then 
            return true, number
        end
    end

    return false, number
end

local function XpersonalmenuKeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
        Citizen.Wait(0)
    end

    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Citizen.Wait(500)
        blockinput = false
        return result
    else
        Citizen.Wait(500)
        blockinput = false
        return nil
    end
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)
 


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if VarColor == "~b~" then VarColor = "~r~" else VarColor = "~b~" end
    end
end)

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Await(10)
    end

    ESX.TriggerServerCallback('SaykoV1:getUserGroup', function(group)
        playergroup = group
    end)
end)

RMenu.Add('SaykoV1', 'main', RageUI.CreateMenu("SaykoV1", "Menu Interaction"))
RMenu.Add('SaykoV1', 'inventaire', RageUI.CreateSubMenu(RMenu:Get('SaykoV1', 'main'), "Inventaire", "Inventaire"))
RMenu.Add('SaykoV1', 'inventaire2', RageUI.CreateSubMenu(RMenu:Get('SaykoV1', 'main'), "Inventaire", "Inventaire"))
RMenu.Add('SaykoV1', 'portefeuille', RageUI.CreateSubMenu(RMenu:Get('SaykoV1', 'main'), "Portefeuille", "Portefeuille"))
RMenu.Add('SaykoV1', 'admin', RageUI.CreateSubMenu(RMenu:Get('SaykoV1', 'main'), "Administration", "Administration"))


Citizen.CreateThread(function()
    while true do
        RageUI.IsVisible(RMenu:Get('SaykoV1', 'main'), true, true, true, function()

            RageUI.Separator("~o~Votre steam : ~s~"..GetPlayerName(PlayerId()))
            RageUI.Separator("~o~Votre ID : ~s~"..GetPlayerServerId(PlayerId()))

            RageUI.ButtonWithStyle(VarColor.."→ ~y~Inventaire", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('SaykoV1', 'inventaire'))

            RageUI.ButtonWithStyle(VarColor.."→ ~s~Portefeuille", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('SaykoV1', 'portefeuille'))

            RageUI.ButtonWithStyle(VarColor.."→~y~ Gestion véhicule", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
            end, RMenu:Get('SaykoV1', ' Gestion véhicule'))

            if playergroup == "mod" or playergroup == "admin" or playergroup == "superadmin" or playergroup == "_dev" or playergroup == "owner" then
                RageUI.ButtonWithStyle(VarColor.."→ ~s~Administration", nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
                end, RMenu:Get('SaykoV1', 'admin'))
            else
                RageUI.ButtonWithStyle(VarColor.."→ ~o~Administration", nil, {RightLabel = RageUI.BadgeStyle.Lock }, false, function(Hovered, Active, Selected)
                if (Selected) then
                end
            end)
        end

        end, function()
        end)
    
            RageUI.IsVisible(RMenu:Get('SaykoV1', 'inventaire'), true, true, true, function()

   

                RageUI.Separator("↓ Votre inventaire : ↓")

                ESX.PlayerData = ESX.GetPlayerData()
                for i = 1, #ESX.PlayerData.inventory do
                    if ESX.PlayerData.inventory[i].count > 0 then
                        RageUI.ButtonWithStyle('[' ..ESX.PlayerData.inventory[i].count.. '] - ~s~' ..ESX.PlayerData.inventory[i].label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                            if (Selected) then
                                Xperso.ItemSelected = ESX.PlayerData.inventory[i]
                            end
                        end, RMenu:Get('SaykoV1', 'inventaire2'))
                    end
                end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('SaykoV1', 'inventaire2'), true, true, true, function()

                RageUI.ButtonWithStyle("Utiliser", nil, {RightBadge = RageUI.BadgeStyle.Heart}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                     if Xperso.ItemSelected.usable then
                         TriggerServerEvent('esx:useItem', Xperso.ItemSelected.name)
                        else
                            ESX.ShowNotification('l\'items n\'est pas utilisable', Xperso.ItemSelected.label)
                            end
                        end
                    end) 
    
                    RageUI.ButtonWithStyle("Jeter", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            if Xperso.ItemSelected.canRemove then
                                local post,quantity = CheckQuantity(XpersonalmenuKeyboardInput("Nombres d'items que vous voulez jeter", '', '', 100))
                                if post then
                                    if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                                        TriggerServerEvent('esx:removeInventoryItem', 'item_standard', Xperso.ItemSelected.name, quantity)
                                    else
                                        ESX.ShowNotification("Vous ne pouvez pas faire ceci dans un véhicule !")
                                    end
                                end
                            end
                        end
                    end)
    
                    RageUI.ButtonWithStyle("Donner", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true, function(Hovered, Active, Selected)
                        if (Selected) then
                            local sonner,quantity = CheckQuantity(XpersonalmenuKeyboardInput("Nombres d'items que vous voulez donner", '', '', 100))
                            local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                            local pPed = GetPlayerPed(-1)
                            local coords = GetEntityCoords(pPed)
                            local x,y,z = table.unpack(coords)
                            DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
        
                            if sonner then
                                if closestDistance ~= -1 and closestDistance <= 3 then
                                    local closestPed = GetPlayerPed(closestPlayer)
        
                                    if IsPedOnFoot(closestPed) then
                                            TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', Xperso.ItemSelected.name, quantity)
                                        else
                                            ESX.ShowNotification("Nombres d'items invalid !")
                                        end
                                else
                                    ESX.ShowNotification("Aucun joueur ~r~Proche~n~ !")
                                    end
                                end
                            end
                        end)


                    end, function()
                    end)



            RageUI.IsVisible(RMenu:Get('SaykoV1', 'portefeuille'), true, true, true, function()


                RageUI.Separator("~r~↓ Votre Portefeuille : ↓")
                RageUI.Separator("Emploi ~c~→ ~b~" .. ESX.PlayerData.job.label .. "~s~ - ~b~" .. ESX.PlayerData.job.grade_label)
                RageUI.Separator("Gang/Orga ~c~→ ~b~" .. ESX.PlayerData.job2.label .. "~s~ - ~b~" .. ESX.PlayerData.job2.grade_label)
                RageUI.Separator("~b~↓ Vos license ↓")


                RageUI.Separator("Argent liquide ~c~→ ~g~" .. ESX.Math.GroupDigits(ESX.PlayerData.money .. "$"))

                RageUI.ButtonWithStyle(' Regarder sa carte d\'identité', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                    end
                end)

                RageUI.ButtonWithStyle('~s~→~y~ Montrer sa carte d\'identité', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))
                        else
                        ESX.ShowNotification("SaykoV1 \nAucun joueur à proximité")
                        end
                    end
                end)

                RageUI.ButtonWithStyle('Regarder son permis de conduire', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
                    end
                end)

                RageUI.ButtonWithStyle('~s~→ ~y~Montrer son permis de conduire', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')
                        else
                        ESX.ShowNotification("SaykoV1 \nAucun joueur à proximité")
                        end
                    end
                end)

                RageUI.ButtonWithStyle(' Regarder son permis port d\'arme', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
                    end
                end)

                RageUI.ButtonWithStyle('~s~→~y~ Montrer son permis port d\'arme', nil, {RightLabel = nil }, true, function(Hovered, Active, Selected)
                    if (Selected) then
                        local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
                        if closestDistance ~= -1 and closestDistance <= 3.0 then
                        TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')
                        else
                        ESX.ShowNotification("SaykoV1 \nAucun joueur à proximité")
                        end
                    end
                end)
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('SaykoV1', 'admin'), true, true, true, function()

                if playergroup == "mod" then
                    RageUI.Separator("~r~[Modérateur] ~s~~y~"..GetPlayerName(PlayerId()))
                elseif playergroup == "admin" then
                    RageUI.Separator("~r~[Administrateur] ~s~~y~"..GetPlayerName(PlayerId()))
                elseif playergroup == "superadmin" then
                    RageUI.Separator("~r~[SuperAdmin] ~s~~y~"..GetPlayerName(PlayerId()))
                elseif playergroup == "_dev" then
                    RageUI.Separator("~r~[Développeur] ~s~~y~"..GetPlayerName(PlayerId()))
                elseif playergroup == "owner" then
                    RageUI.Separator("~r~[Créateur] ~s~~y~"..GetPlayerName(PlayerId()))    
                end
            
                RageUI.Separator("~c~↓ ~s~Administrations ~c~↓")
            RageUI.Checkbox("→ Activer la ~b~Modération",nil, service,{},function(_,_,s,Checked)
                if s then
                    ESX.ShowNotification("~g~Activation du mode staff...")
                    service = Checked
                    if Checked then
                        onservice = true
                        local head = RegisterPedheadshot(PlayerPedId())
                        while not IsPedheadshotReady(head) or not IsPedheadshotValid(head) do
                            Wait(1)
                        end
                        headshot = GetPedheadshotTxdString(head)
                    else
                        ESX.ShowNotification("~r~Désactivation du mode staff...")
                        onservice = false
                        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                        TriggerEvent('skinchanger:loadSkin', skin)
                        end)
                    end
                end
            end)
            if onservice then

                RageUI.ButtonWithStyle("→ Menu Administration", nil, {RightLabel = "→→"},true, function()
                end, RMenu:Get('SaykoV1', 'administration'))

                RageUI.ButtonWithStyle("→ Menu Véhicule", nil, {RightLabel = "→→"},true, function()
                end, RMenu:Get('SaykoV1', 'admin_vehicule'))
            end
            
            RageUI.ButtonWithStyle("~s~→ ~y~Faire un report !", nil, {RightLabel = "→→"}, true, function(_,_,s)
                if s then
                    local raison = KeyboardInput("Raison de votre report", "", 45)
                    ExecuteCommand("report "..raison)
                end
            end)    
            end, function()
            end)




            Citizen.Wait(0)
        end
    end)






Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 166) then
            RageUI.Visible(RMenu:Get('SaykoV1', 'main'), not RageUI.Visible(RMenu:Get('SaykoV1', 'main')))
        end
    end
end)
