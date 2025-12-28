
# !/bin/bash





cat <<EOF | confluent kafka topic produce onchainsentinel_tx --value-format avro
{"chain":"ethereum-mainnet","txId":"0x9b6a68cf6c3cc326915b2231dcdb0e7cd2218ffedefa4851f15d9b36d96e19f9","address":"0x8e0b5395B813E75dA6a44c813cD41497A962D2bE","to_address":"0x79815097EC9c73ed1aBcf8f3442948B228889D4d","amount":"0.00001 ETH","ts":"1736139767"}
{"chain":"ethereum-mainnet","txId":"0x17276519456ffabd9520b16aa68dd3784ef2bedba0fbdfb6f5712673c80d18c8","address":"0x31BE367443E18458A2784AD7B0bA9224B6c25d72","to_address":"0xb231759890157ca3bd7d664B9795796660374752","amount":"6,012 ETH","ts":"1656680770"}
{"chain":"ethereum-mainnet","txId":"0xcc009864fb75c127d3269d6adf950819eeb4db321193cf89a80574c1386f8fba","address":"0x0d043128146654C7683Fbf30ac98D7B2285DeD00","to_address":"0x9E91ae672E7f7330Fc6B9bAb9C259BD94Cd08715","amount":"70,000 DAI","ts":"1655989341"}
EOF

