"use strict";

// integrations/sync/client/flows/auth.ts
var API_URL = GetConvar("snailycad_url", "null");
emit(
  "chat:addSuggestion",
  `/${"sn-whoami" /* WhoAmI */}`,
  "Shows your current SnailyCAD account username and ID that is connected to the game."
);
emit(
  "chat:addSuggestion",
  `/${"sn-auth" /* Auth */}`,
  "Authenticate with your personal SnailyCAD API Token to interact with parts of it."
);
onNet("sna-sync:request-authentication-flow" /* RequestAuthFlow */, () => {
  SendNuiMessage(
    JSON.stringify({ action: "sna-sync:request-authentication-flow" /* RequestAuthFlow */, data: { url: API_URL, source } })
  );
  SetNuiFocus(true, true);
});
RegisterNuiCallbackType("sna-sync-nui:authentication-flow-success" /* OnAuthenticationFlowSuccess */);
on(`__cfx_nui:${"sna-sync-nui:authentication-flow-success" /* OnAuthenticationFlowSuccess */}`, (data, cb) => {
  emitNet("sna-sync:on-user-save" /* OnUserSave */, data);
  cb({ ok: true });
});

// integrations/sync/client/flows/unit-status.ts
var API_URL2 = GetConvar("snailycad_url", "null");
emit(
  "chat:addSuggestion",
  `/${"sn-active-unit" /* ActiveUnit */}`,
  "This will show your active unit's name and status."
);
emit(
  "chat:addSuggestion",
  `/${"sn-set-status" /* SetStatus */}`,
  "This will open a menu and will allow you to select a status for your active unit.",
  [{ name: "status-code", help: "The status code you want to set (Optional)." }]
);
onNet(
  "sna-sync:request-set-status-flow" /* RequestSetStatusFlow */,
  (unitId, source2, userApiToken, statusCodes) => {
    SendNuiMessage(
      JSON.stringify({
        action: "sna-sync:request-set-status-flow" /* RequestSetStatusFlow */,
        data: { url: API_URL2, source: source2, unitId, userApiToken, statusCodes }
      })
    );
    SetNuiFocus(true, true);
  }
);

// integrations/sync/client/flows/911-call-attach.ts
var API_URL3 = GetConvar("snailycad_url", "null");
emit(
  "chat:addSuggestion",
  `/${"sn-attach" /* AttachTo911Call */}`,
  "Attach your active unit to a 911 call.",
  [{ name: "case-number", help: "The case number of the 911 call (Optional)." }]
);
onNet(
  "sna-sync:request-call-911-attach-flow" /* RequestCall911AttachFlow */,
  (unitId, source2, calls, userApiToken) => {
    SendNuiMessage(
      JSON.stringify({
        action: "sna-sync:request-call-911-attach-flow" /* RequestCall911AttachFlow */,
        data: { url: API_URL3, userApiToken, source: source2, unitId, calls }
      })
    );
    SetNuiFocus(true, true);
  }
);
var POSTAL_COMMAND = GetConvar("snailycad_postal_command", "null");
onNet("sna-sync:attach-postal" /* AutoPostalOnAttach */, (postal) => {
  const postalCodeAsInt = parseInt(postal);
  if (POSTAL_COMMAND === "null") {
    console.info(`
---------------------------------------

[${GetCurrentResourceName()}] Not automatically setting postal code for call. There was no postal command set.:
\`setr snailycad_postal_command "<your-command-here>" \`

---------------------------------------`);
    return;
  }
  if (postalCodeAsInt > 0) {
    ExecuteCommand(`${POSTAL_COMMAND} ${postalCodeAsInt}`);
  } else {
    emit("chat:addMessage", {
      color: [255, 0, 0],
      multiline: true,
      args: ["SnailyCAD", "An error occured while making route to call postal"]
    });
  }
});

// integrations/sync/client/flows/traffic-stop.ts
emit(
  "chat:addSuggestion",
  `/${"sn-traffic-stop" /* TrafficStop */}`,
  "Create a call with your current position and be assigned as primary unit.",
  [{ name: "description", help: "The description of your traffic stop" }]
);
onNet(
  "sna-sync:request-traffic-stop-flow" /* RequestTrafficStopFlow */,
  (data) => {
    const playerPed = GetPlayerPed(-1);
    const [x, y, z] = GetEntityCoords(playerPed, true);
    const [lastStreet] = GetStreetNameAtCoord(x, y, z);
    const lastStreetName = GetStreetNameFromHashKey(lastStreet);
    const heading = GetEntityHeading(PlayerPedId());
    setImmediate(() => {
      emitNet("sna-sync:on-traffic-stop-client-position" /* OnTrafficStopClientPosition */, {
        ...data,
        streetName: lastStreetName,
        position: { x, y, z, heading }
      });
    });
  }
);

// integrations/sync/client/client.ts
var API_URL4 = GetConvar("snailycad_url", "null");
if (API_URL4 === "null") {
  console.error(`
  ---------------------------------------

[${GetCurrentResourceName()}] Failed to find the "snailycad_url" convar in your server.cfg. Please make sure you are using \`setr\` and not \`set\`:

\`setr snailycad_url "<api-url-here>/v1" \`

  ---------------------------------------`);
}
emit(
  "chat:addSuggestion",
  `/${"sn-panic-button" /* PanicButton */}`,
  "Toggle the panic button state for your active unit."
);
on("onClientResourceStart", (resource) => {
  if (resource !== GetCurrentResourceName())
    return;
  const currentResourceVersion = GetResourceMetadata(GetCurrentResourceName(), "version");
  setTimeout(() => {
    SendNuiMessage(
      JSON.stringify({
        action: "sn:initialize",
        data: { version: currentResourceVersion, url: API_URL4 }
      })
    );
  }, 500);
});
onNet(
  "sna-sync:create-notification" /* CreateNotification */,
  (options) => {
    SendNuiMessage(
      JSON.stringify({
        action: "sna-sync:create-notification" /* CreateNotification */,
        data: { ...options, url: API_URL4 }
      })
    );
  }
);
RegisterNuiCallbackType("sna-sync-nui:connected" /* Connected */);
on(`__cfx_nui:${"sna-sync-nui:connected" /* Connected */}`, (_data, cb) => {
  console.info("Connected to SnailyCAD!");
  cb({ ok: true });
});
RegisterNuiCallbackType("sna-sync-nui:close-nui" /* CloseNui */);
on(`__cfx_nui:${"sna-sync-nui:close-nui" /* CloseNui */}`, (_data, cb) => {
  SetNuiFocus(false, false);
  cb({ ok: true });
});
RegisterNuiCallbackType("sna-sync-nui:connect_error" /* ConnectionError */);
on(`__cfx_nui:${"sna-sync-nui:connect_error" /* ConnectionError */}`, (data, cb) => {
  console.info((data == null ? void 0 : data.message) ?? (data == null ? void 0 : data.name) ?? (String(data) || "Unknown error"));
  console.info("Unable to connect to SnailyCAD. Error:", data);
  cb({ ok: true });
});
RegisterNuiCallbackType("sna-sync-nui:create-911-call" /* Create911Call */);
on(`__cfx_nui:${"sna-sync-nui:create-911-call" /* Create911Call */}`, (data, cb) => {
  emitNet("sna-sync:incoming-911-call" /* Incoming911Call */, data);
  cb({ ok: true });
});
RegisterNuiCallbackType("sna-sync-nui:panic-button-on" /* PanicButtonOn */);
on(`__cfx_nui:${"sna-sync-nui:panic-button-on" /* PanicButtonOn */}`, (data, cb) => {
  emitNet("sna-sync:panic-button-on" /* PanicButtonOn */, data);
  cb({ ok: true });
});
