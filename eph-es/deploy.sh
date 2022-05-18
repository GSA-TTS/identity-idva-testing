#!/bin/bash

env=dev
secrets_file="sk-secrets-dev.json"

echo "press key to continue to next step:"
read -pr "1. Deploy elasticsearch app"

cf push --vars-file ./vars.yaml --var ENVIRONMENT=$env

read -pr "2. Network policies"

cf add-network-policy sk-esconfigs eph-es --protocol tcp --port 61443
cf add-network-policy sk-events eph-es --protocol tcp --port 61443
cf add-network-policy sk-events-read eph-es --protocol tcp --port 61443
cf add-network-policy sk-analytics eph-es --protocol tcp --port 61443

read -pr "3. configure secrets"

jq --arg env "$env" '.es.usePath = false | .es.url = "identity-idva-es-$env.apps.internal:61443" | .es.accessKeyId = "id" | .es.secretAccessKey = "sec"' "$secrets_file" > sk-secrets-es.json

read -pr "4. configure sk-esconfigs, sk-events, sk-events-read, sk-analytics"

cf set-env sk-esconfigs SK_SECRETS "$(cat sk-secrets-es.json)"
cf set-env sk-events SK_SECRETS "$(cat sk-secrets-es.json)"
cf set-env sk-events-read SK_SECRETS "$(cat sk-secrets-es.json)"
cf set-env sk-analytics SK_SECRETS "$(cat sk-secrets-es.json)"

cf set-env sk-esconfigs NODE_EXTRA_CA_CERTS /etc/cf-system-certificates/trusted-ca-1.crt
cf set-env sk-events NODE_EXTRA_CA_CERTS /etc/cf-system-certificates/trusted-ca-1.crt
cf set-env sk-events-read NODE_EXTRA_CA_CERTS /etc/cf-system-certificates/trusted-ca-1.crt
cf set-env sk-analytics NODE_EXTRA_CA_CERTS /etc/cf-system-certificates/trusted-ca-1.crt

read -pr "5. run sk-esconfigs"

cf run-task sk-esconfigs --name task

read -pr "6. restart sk-events, sk-events-read, sk-analytics"

cf restart sk-events
cf restart sk-events-read
cf restart sk-analytics
