

# !/bin/bash


confluent schema-registry schema delete --subject onchainsentinel_tx-value  --version latest
confluent schema-registry schema delete --subject onchainsentinel_risk_address-value  --version latest
confluent schema-registry schema delete --subject onchainsentinel_risk_tx-value  --version latest
confluent schema-registry schema delete --subject onchainsentinel_history_tx-value  --version latest





