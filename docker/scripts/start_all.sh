#!/bin/sh

set -e

# Start algod
cp node/genesisfiles/${ALGORAND_NETWORK}/genesis.json ${ALGORAND_DATA}
echo "INFO: Starting Algod"
/algorand/node/algod -l 0.0.0.0:8080 &
sleep 5

# Store algod.token and algod.admin.token in kubernetes secret. Tokens are shared among node instances when replicas are greater than 1. 
export token=`kubectl get secrets/algon-api-token -o json  | jq .data | jq -r '."algod.token"' | base64 -d`
if [ "$token" = "null" ]; then
    echo "INFO: Algod Token(s) not found, creating new ones in cluster,"
    kubectl create secret generic algon-api-token \
                --from-file=node/data/algod.token \
                --from-file=node/data/algod.admin.token \
                --save-config \
                --dry-run=client \
                -o yaml |
                kubectl apply -f -
else
    echo "INFO: Algod Tokens found in cluster, refreshing local copy."
    echo `kubectl get secrets/algon-api-token -o json  | jq .data | jq -r '."algod.token"' | base64 -d` >  node/data/algod.token
    echo `kubectl get secrets/algon-api-token -o json  | jq .data | jq -r '."algod.admin.token"' | base64 -d` >  node/data/algod.admin.token
fi
export ALGON_TOKEN="$(cat node/data/algod.token)"
export token=

echo "INFO: Algod Node current status"
/algorand/node/goal node status
echo "INFO: Fast catchup only if more than 10000 rounds are missing."
/algorand/node/goal node catchup --force -m 10000 &

# Do not kill the pod and print a JSON status line every minute
while true; do
    curl --location "http://localhost:8080/v2/status?format=json" --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-Algo-API-Token: ${ALGON_TOKEN}"
    sleep 60
done
