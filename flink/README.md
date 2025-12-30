
# ֎ Model creation
Note: Unfortunatly we could not use managed models (available only in AWS specific region) and opt for a remote AI model

Apply SQL in this exact order or check  details below for more information

Open an shell and enter the 3 commands
---
1. 01_create_connection.sql
2. 02_create_model.sql
3. 03_create_straming_risk_tx.sql

---

## 🔌 Remote AI model Gemini AI

Generate an API Key from https://aistudio.google.com/app/apikey.

The endpoint is https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview.

Gemini models are also supported through the Gemini AI provider, which you may prefer due to integrated Google Cloud billing.

1. Create Connection

```
CREATE CONNECTION googleai_connection
WITH (
  'type' = 'googleai',
  'endpoint' = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash:generateContent',
  'api-key' = '<your-gcp-api-key>'
);
```

```
SHOW CONNECTIONS;
```

```
DROP CONNECTION googleai_connection;
```


2. CREATE MODEL
```
CREATE MODEL model_tx_analyzer
INPUT (
    tx_payload STRING
)
OUTPUT (
    json_result STRING 
)
WITH (
  'googleai.connection' = 'googleai_connection',
  'googleai.system_prompt' = 'You are a blockchain fraud risk classifier. \
Evaluate raw transaction data using fraud behavioral or fraud patterns indicators. \
Respond ONLY with a JSON object containing "risk_level" and "reason". \
risk_level must be LOW, MEDIUM, or HIGH. reason must be a single short sentence.',
  'provider' = 'googleai',
  'task' = 'text_generation'
);

```

```
SHOW MODELS;
```


```
DROP MODEL model_tx_analyzer;
```
---


## 🎞️ Create Streaming using Flink AI


Step 1. Merge the result from AI with kafka topic details
```
  SELECT 
    *
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT('model_tx_analyzer', CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    )));
```


Step 2. Make all the details available
```
SELECT
    txId,
    chain,
    address,
    to_address,
    amount,
    ts,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.risk_level'
    ) AS risk,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.reason'
    ) AS reason
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT(
    'model_tx_analyzer',
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    )
  )
);
```

Step 3. Create a view ❌
```
CREATE VIEW onchainsentinel_tx_risk_stream AS
SELECT
    txId,
    chain,
    address,
    to_address,
    amount,
    ts,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.risk_level'
    ) AS risk,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.reason'
    ) AS reason
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT(
    'model_tx_analyzer',
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    )
  )
) AS T(prediction);
```

Step 4. Continous stream 

```
INSERT INTO onchainsentinel_risk_tx
SELECT
    CAST(txId AS BYTES) AS key,
    txId AS tx_id,
    address,
    chain,
    'model_tx_analyzer' AS model_name,
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    ) AS origin_tx,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.risk_level'
    ) AS risk,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.reason'
    ) AS reason
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT(
    'model_tx_analyzer',
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    )
  )
);
```


## Check if the job is running
```

export FLINK_POOL_ID=$(
  confluent flink compute-pool list -o json \
    | jq -r '.[] | select(.name=="onchainsentinel-flink") | .id'
)
confluent flink statement list --compute-pool $FLINK_POOL_ID -o json | jq '.[] | select(.status == "RUNNING")'
```

## Delete job




