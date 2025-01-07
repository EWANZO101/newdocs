-- Register the 'cad-911' event
RegisterNetEvent('cad-911')
AddEventHandler('cad-911', function()
    print("SnailyCad Error Code:")

    -- Perform HTTP Request to SnailyCAD API
    PerformHttpRequest('https://api.exmaple.com/v1/911-calls', function(err, text, headers)
        -- Print error codes if any
        if err ~= 0 then
            print("Error: " .. err)
            if err == 400 then
                print("Bad Request - The server could not understand the request.")
            elseif err == 401 then
                print("Unauthorized - Invalid API token.")
            elseif err == 403 then
                print("Forbidden - Access denied.")
            elseif err == 404 then
                print("Not Found - Endpoint does not exist.")
            elseif err == 500 then
                print("Internal Server Error - Try again later.")
            elseif err == 502 then
                print("Bad Gateway - Invalid response from upstream server.")
            elseif err == 503 then
                print("Service Unavailable - Server might be down for maintenance.")
            else
                print("Unknown Error - Contact support.")
            end
        else
            print("Success: 911 call submitted successfully.")
        end
    end, 'POST', json.encode({
        name = "Local 911 Caller",
        location = "Test Road",
        postal = "3010",
        gtaMapPostion = {
            x = "100",
            y = "100",
            z = "100",
            heading = "100"
        },
        descriptionData = {{
            type = "paragraph",
            children = {{
                text = "Test 911 call"
            }}
        }}
    }), {
        ['Content-Type'] = 'application/json',
        ['snaily-cad-api-token'] = "REPLACE WITH YOUR API TOKEN ON CAD SETTINGS"
    })
end)

-- Trigger the 'cad-911' event for testing
TriggerEvent('cad-911')
