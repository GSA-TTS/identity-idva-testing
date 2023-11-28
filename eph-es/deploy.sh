#!/bin/bash

env=dev
# Path to current sk-secrets file
secrets_file="sk-secrets-$env.json"

# The 'read' command pauses execution of the script until the user is ready to continue.
echo "press key to continue to next step:"
read -rp "1. Deploy elasticsearch app"

cf target -s "$env"
cf push --vars-file ./vars.yaml --var ENVIRONMENT=$env

read -rp "2. Network policy for esconfigs"

cf add-network-policy sk-esconfigs eph-es --protocol tcp --port 61443

read -rp "3. configure secrets"

# settings es configuration in sk secrets to point to eph-es
jq --arg env "$env" '.es.usePath = false | .es.url = "idva-eph-es-\($env).apps.internal:61443" | .es.accessKeyId = "id" | .es.secretAccessKey = "sec"' "$secrets_file" > sk-secrets-es.json

read -rp "4. configure sk-esconfigs"

cf unbind-service sk-esconfigs sk-secrets
cf set-env sk-esconfigs SK_SECRETS "$(cat sk-secrets-es.json)"

read -rp "5. run sk-esconfigs"

cf run-task sk-esconfigs --name task

read -rp "6. Network policies for analytics"

cf add-network-policy sk-events eph-es --protocol tcp --port 61443
cf add-network-policy sk-events-read eph-es --protocol tcp --port 61443
cf add-network-policy sk-analytics eph-es --protocol tcp --port 61443

read -rp "7. configure sk-events, sk-events-read, sk-analytics"

cf unbind-service sk-events sk-secrets
cf unbind-service sk-events-read sk-secrets
cf unbind-service sk-analytics sk-secrets

cf set-env sk-events SK_SECRETS "$(cat sk-secrets-es.json)"
cf set-env sk-events-read SK_SECRETS "$(cat sk-secrets-es.json)"
cf set-env sk-analytics SK_SECRETS "$(cat sk-secrets-es.json)"

read -rp "8. restart sk-events, sk-events-read, sk-analytics"

cf restart sk-events
cf restart sk-events-read
cf restart sk-analytics

read -rp "9. configure gdrive"

cf add-network-policy gdrive eph-es --protocol tcp --port 8080
cf set-env gdrive ES_HOST "idva-eph-es-$env.apps.internal"
cf restage gdrive
