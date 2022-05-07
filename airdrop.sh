#!/bin/bash

FAUCET_URL="http://127.0.0.1:3333/request_neon"
PROXY_URL="http://127.0.0.1:9090/solana"

NEON_AMOUNT=1000

NEON_ACCOUNT_LIST=$(sudo \
  docker exec -ti proxy ./proxy-cli.sh account list | \
  awk ' /Account/ { print substr($3,2,length($3)-2)}' | \
  sort | \
  awk '{print $1}')


function get_balance() {
    local NEON_ACCOUNT=$1

    REQUEST='{"jsonrpc": "2.0", "method": "eth_getBalance", "params": ["0x'${NEON_ACCOUNT}'", "latest"], "id": 1}'
    RESPONSE=$(curl ${PROXY_URL} -X POST -H "Content-Type: application/json" -d "${REQUEST}" 2> /dev/null)
    RESULT=$(python3 -c "print(f'{int(${RESPONSE}[\"result\"][2:],16)/pow(10,18):,.18f}')")
    echo ${RESULT}
}

for NEON_ACCOUNT in $NEON_ACCOUNT_LIST
do
    NEON_BALANCE=$(get_balance ${NEON_ACCOUNT})
    echo "Account {${NEON_ACCOUNT}}:"
    echo "  - start balance: ${NEON_BALANCE}"
    echo "  - request: ${NEON_AMOUNT} NEONs ..."

    REQUEST='{"amount":'${NEON_AMOUNT}', "wallet":"0x'${NEON_ACCOUNT}'"}'
    curl ${FAUCET_URL} -X POST -H "Content-type: application/json" -d "${REQUEST}" 2> /dev/null

    NEON_BALANCE=$(get_balance ${NEON_ACCOUNT})
    echo "  - result balance: ${NEON_BALANCE}"
    echo
done
