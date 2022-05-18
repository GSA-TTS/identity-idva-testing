#!/bin/bash

secrets_file="sk-secrets-dev.json"

echo "press key to continue to next step:"
read -pr "1. restore app config"

cf set-env sk-esconfigs SK_SECRETS "$(cat $secrets_file)"
cf set-env sk-events SK_SECRETS "$(cat $secrets_file)"
cf set-env sk-events-read SK_SECRETS "$(cat $secrets_file)"
cf set-env sk-analytics SK_SECRETS "$(cat $secrets_file)"

cf unset-env sk-esconfigs NODE_EXTRA_CA_CERTS
cf unset-env sk-events NODE_EXTRA_CA_CERTS
cf unset-env sk-events-read NODE_EXTRA_CA_CERTS
cf unset-env sk-analytics NODE_EXTRA_CA_CERTS

read -pr "2. restart apps"

cf restart sk-events
cf restart sk-events-read
cf restart sk-analytics

read -pr "3. delete es"	

cf delete eph-es