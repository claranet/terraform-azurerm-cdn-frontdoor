#!/bin.bash

# Location is a mandatory parameter but FrontDoor service is global, so "westeurope" is not used here but mandatory ¯\_(ツ)_/¯
BACKEND_PREFIXES=$(az network list-service-tags --location westeurope --query "values[?id=='AzureFrontDoor.Backend'].properties | [0].addressPrefixes" -o json)
FRONTEND_PREFIXES=$(az network list-service-tags --location westeurope --query "values[?name=='AzureFrontDoor.Frontend'].properties | [0].addressPrefixes" -o json)
FIRSTPARTY_PREFIXES=$(az network list-service-tags --location westeurope --query "values[?name=='AzureFrontDoor.FirstParty'].properties | [0].addressPrefixes" -o json)

jq -n \
  --arg backend_prefixes "$BACKEND_PREFIXES" \
  --arg frontend_prefixes "$FRONTEND_PREFIXES" \
  --arg firstparty_prefixes "$FIRSTPARTY_PREFIXES" \
  '{"backendPrefixes":$backend_prefixes, "frontendPrefixes":$frontend_prefixes, "firstpartyPrefixes":$firstparty_prefixes}'
