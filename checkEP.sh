#!/bin/bash

# Usage: ./check_entrypoint_and_eip155.sh <RPC_ENDPOINT>

RPC_ENDPOINT=$1
ENTRYPOINT_ADDRESS="0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789"

# Check if the RPC endpoint is provided
if [ -z "$RPC_ENDPOINT" ]; then
    echo "Usage: ./check_entrypoint_and_eip155.sh <RPC_ENDPOINT>"
    exit 1
fi

# Check EntryPoint deployment
ENTRYPOINT_CODE=$(curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$ENTRYPOINT_ADDRESS\", \"latest\"],\"id\":1}" -H "Content-Type: application/json" "$RPC_ENDPOINT")

if [[ $ENTRYPOINT_CODE == *"0x"* && $ENTRYPOINT_CODE != *"\"result\":\"0x\""* ]]; then
    echo "EntryPoint is deployed ✅"
    exit 0
elif [[ $ENTRYPOINT_CODE == *"\"result\":\"0x\""* ]]; then

    # Dummy pre-EIP-155 transaction data
    TRANSACTION_DATA='{"jsonrpc":"2.0","method":"eth_sendRawTransaction","params":["0xf866808609184e72a0008302710094000000000000000000000000000000000000000080801ca0ad717d4719e7b7f2192de1bc85e1638c32b02f9873252195b94bb09be418450ca036b9723c20288faf66a2f67017aeb3d6e70f725a082b300aa13c87efe2d66e4b"],"id":1}'

    # Attempt to send the dummy transaction
    RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" --data "$TRANSACTION_DATA" "$RPC_ENDPOINT")

    # Check the response for pre-EIP-155 support
    if echo "$RESPONSE" | grep -q "only replay-protected (EIP-155) transactions allowed over RPC"; then
        echo "EntryPoint not deployed and pre-EIP-155 not supported ❌"
    else
        echo "EntryPoint not deployed, but pre-EIP-155 supported ✅"
    fi
else
    echo "Unable to verify EntryPoint deployment. Response: $ENTRYPOINT_CODE"
fi
