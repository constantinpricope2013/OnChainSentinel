
# !/bin/bash


confluent schema-registry schema create \
--subject onchainsentinel_tx-value \
 --type AVRO \
 --schema kafka/avro_tx_raw.avsc



confluent schema-registry schema create  \
 --subject onchainsentinel_risk_address-value \
 --type AVRO \
 --schema kafka/avro_risk_address.avsc




confluent schema-registry schema create  \
 --subject onchainsentinel_risk_tx-value \
 --type AVRO \
 --schema kafka/avro_risk_tx.avsc



confluent schema-registry schema create  \
 --subject onchainsentinel_history_tx-value \
 --type AVRO \
 --schema kafka/avro_history_tx.avsc


