function GetDoorInfo()
    -- Get player and camera coordinates
    local playerPed = PlayerPedId()
    local camCoords = GetGameplayCamCoord()
    local forwardVector = GetCamForwardVector()

    -- Calculate the target position
    local targetCoords = camCoords + (forwardVector * 10.0)

    -- Raycast to find objects
    local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, 16, playerPed, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    -- Check if we hit an entity
    if hit == 1 and DoesEntityExist(entityHit) then
        local model = GetEntityModel(entityHit)
        local doorHash = GetHashKey(model)
        local heading = GetEntityHeading(entityHit)
        local coords = GetEntityCoords(entityHit)
        local min, max = GetModelDimensions(model)
        local offset = (max - min) / 2.0 -- Calculate the shell offset

        print("Door Info:")
        print("Model: " .. model)
        print("Hash: " .. doorHash)
        print("Heading: " .. heading)
        print("Coords: " .. coords.x .. ", " .. coords.y .. ", " .. coords.z)
        print("Offset: " .. offset.x .. ", " .. offset.y .. ", " .. offset.z)
    else
        print("No door found.")
    end
end

-- Keybind to trigger the function when the player aims with a gun
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsPlayerFreeAiming(PlayerId()) then -- Check if the player is aiming
            if IsControlJustPressed(0, 38) then -- E key
                GetDoorInfo()
            end
        end
    end
end)