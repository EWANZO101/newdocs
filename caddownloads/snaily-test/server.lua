RegisterNetEvent('cad-911')
AddEventHandler('cad-911', function()
print("SnailyCad Error Code:")
PerformHttpRequest('https://api.exmaple.com/v1/911-calls', function(err, text, headers)
print(err)
        end, 'POST', json.encode({
            name = "Local 911 Caller",
			location = "Test Road",    
			--description = callout,
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
			text = "Test 911 call",
			}}
			}}
        }), 
		{
            ['Content-Type'] = 'application/json',
			['snaily-cad-api-token'] = "REPLACE WITH YOUR API TOKEN oN CAD SETTINGS"
        })

end)

TriggerEvent('cad-911')