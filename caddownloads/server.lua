RegisterNetEvent('cad-911')
AddEventHandler('cad-911', function()
print("SnailyCad Error Code:")
PerformHttpRequest('https://projectfallsmdc-api.snailycad.co.uk/v1/911-calls', function(err, text, headers)
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
			['snaily-cad-api-token'] = "sng_iwjWjoKGo5z48pCOtutEsmUY03REZSnpkUJegfT_Zz36v_HhXFlAjeI-"
        })

end)

TriggerEvent('cad-911')