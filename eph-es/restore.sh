#!/bin/bash

env="dev"

# The 'read' command pauses execution of the script until the user is ready to continue.
echo "press key to continue to next step:"
read -rp "1. restore app config"

cf unset-env sk-events SK_SECRETS
cf unset-env sk-events-read SK_SECRETS
cf unset-env sk-analytics SK_SECRETS

cf bind-service sk-events sk-secrets
cf bind-service sk-events-read sk-secrets
cf bind-service sk-analytics sk-secrets

read -rp "2. restart apps"

cf restart sk-events
cf restart sk-events-read
cf restart sk-analytics

read -rp "3. delete es"	

cf delete eph-es

read -rp "4. restore gdrive"

cf set-env gdrive ES_HOST "identity-idva-es-proxy-$env.apps.internal"
cf restage gdrive
