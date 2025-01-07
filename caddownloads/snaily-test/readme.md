# Instructions for Configuring Your CAD API in server.lua

## Step 1: Open the server.lua File
Open the `server.lua` file in your code editor.

## Step 2: Replace the API URL
Find the following line:
```
https://api.example.com
```
Replace it with your **CAD API URL**.

## Step 3: Update the API Token
Scroll to the bottom of the file and locate this line:
```
['snaily-cad-api-token'] = "REPLACE WITH YOUR API TOKEN ON CAD SETTINGS"
```
Replace the text in quotes with your **actual API token** from the CAD settings.

## Step 4: Save and Restart
Save the changes and restart the server to apply the updates.

---

# Error Codes and Troubleshooting

### Error Code 400 – BAD
- The server could not understand the request. Verify the request format.

### Error Code 401 – BAD
- Unauthorized - Invalid API token. Ensure the API token is correct.

### Error Code 403 – BAD
- Forbidden - Cannot connect to CAD API. Check permissions and firewall settings.

### Error Code 404 – BAD
- Endpoint does not exist. Verify the API URL.

### Error Code 408 – BAD
- Request Timeout - The server took too long to respond. Check network connectivity.

### Error Code 429 – BAD
- Too Many Requests - Rate limit exceeded. Wait before retrying.

### Error Code 500 – BAD
- Internal Server Error - Try again later or contact support.

### Error Code 502 – BAD
- Bad Gateway - Invalid response from upstream server.

### Error Code 503 – BAD
- Service Unavailable - Server might be down for maintenance. Retry later.

### Error Code 200 – GOOD
- Your API is **working correctly** and is **reachable**.  

### Error Code 0 – BAD
- This means there are **too many quotation marks** in the **server.lua** file.  
- Carefully review the code for **extra or misplaced quotation marks** and fix them.  

---

# Recommended Hosting Providers
- [Mellowservices.com](https://mellowservices.com)
- [Swift Peak Hosting](https://www.swiftpeakhosting.co.uk/VPS)

---

# Script Information
This script was created by **treubig** on Discord.

---

# Need Help?
For further assistance, ping **ewanzo101** or **treubig** in the **SnailyCAD Discord**.
