# OnChainSentinel (Minimal PoC with Confluent Managed AI · Gemma 2 2b-it)

This repository contains a minimal Proof of Concept demonstrating:
- Real-time behavior ingestion (Kafka)
- AI enrichment **in-stream** via Confluent Cloud Flink + `google/gemma-2-2b-it`
- Risk output to a downstream Kafka topic
- Optional sink to BigQuery on Google Cloud

Architecture: Kafka → Flink (Gemma) → Kafka → (optional BigQuery)

This aligns with:
- Confluent AI docs
- Flink on Confluent Cloud Quickstart
- Confluent Cloud Connectors
- Challenge requirements for continuous AI inference on data-in-motion

---

## ONE-TIME SETUP

### Login to Confluent & select env/cluster

```
confluent login
```


## Environment
```
confluent environment create onchainsentinel
confluent environment list # Optional to list environments
confluent environment use <env-id>
confluent environment delete <env-id>
```



## Cluster

```
confluent kafka cluster delete lkc-orxjxx
confluent kafka cluster list # Optional to list the clusters
confluent kafka cluster use <lkc-id>
```


### Create topics
```
bash kafka/topics.sh
```

### Create Flink compute pool 
```
confluent flink compute-pool create onchainsentinel-flink --cloud gcp --region us-east1 --max-cfu 5
```

```
confluent flink compute-pool list # Optional to list compute pools
confluent flink compute-pool use <pool-id>
```

```
confluent flink compute-pool delete <pool-id>
```

### Register shema
```
confluent schema-registry schema create   --subject onchainsentinel.behavior.raw-value   --type AVRO   --schema kafka/avro_behavior_raw.avsc

confluent schema-registry schema create   --subject onchainsentinel.risk.scores-value   --type AVRO   --schema kafka/avro_risk_scores.avsc

confluent schema-registry schema list # To list
confluent schema-registry schema describe --subject onchainsentinel.behavior.raw-value --version latest # To describe
```



```
confluent schema-registry schema delete --subject onchainsentinel.behavior.raw-value  --version latest
confluent schema-registry schema delete --subject onchainsentinel.behavior.raw-value  --version latest
```


### Start Flink SQL shell

```
confluent flink shell --compute-pool <pool-id> --database <lkc-id>
```

Note: Ctrl + Q to exit shell


# Model creation
Note: Unfortunatly we could not use managed models (available only in AWS specific region) and opt for a remote AI model

## Remote AI model Google AI

Generate an API Key from https://aistudio.google.com/app/apikey.

The endpoint is https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent.

Gemini models are also supported through the Vertex AI provider, which you may prefer due to integrated Google Cloud billing.

1. Create Connection

```
CREATE CONNECTION googleai_connection
WITH (
  'type' = 'googleai',
  'endpoint' = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
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
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'googleai_connection',
  'googleai.system_prompt' = 'You are a blockchain AI risk classifier.\\nClassify the following transaction as HIGH, MEDIUM, or LOW risk',
  'provider' = 'googleai',
  'task' = 'text_generation'
);
```

```
SHOW MODELS;
```


```
DROP MODEL model_tx_analyzer
```

## Remote AI model Vertex AI



### Apply SQL in this exact order



:> flink/01_behavior_raw.sql
:> flink/02_behavior_prompt.sql
:> flink/03_behavior_risk_scores.sql
:> flink/04_model_create_managed_gemma.sql
:> flink/05_ai_enrichment.sql


---

## TEST ROUND

### Run producer once
python kafka/producer.py

### Check enriched risk stream
confluent kafka topic consume onchainsentinel.risk.scores --from-beginning

Expected:
{"address":"0xTEST"...,"response_text":"SUSPICIOUS: abnormal burstiness"}