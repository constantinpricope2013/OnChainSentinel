# Login
```
confluent login
```

# (Optional) Create a new environment
```
confluent environment create onchainsentinel-env
confluent environment use <env-id>
```

# Create a Basic / Standard Kafka cluster (GCP region to satisfy hackathon)

```
confluent kafka cluster create onchainsentinel-cluster \
  --cloud gcp --region europe-west3 --type basic

```

```
confluent kafka cluster use <lkc-id>

```

# Create a Flink compute pool (note: managed models currently run only in specific regions, often AWS us-east-1;
# you can still point Flink to the same Kafka cluster cross-cloud).

```
confluent flink compute-pool create onchainsentinel-flink \
  --cloud aws \
  --region us-east-1 \
  --max-cfu 5

```


```
confluent flink compute-pool use <pool-id>

```


# Create topics (CLI)
```
confluent kafka topic create onchainsentinel.behavior.raw
confluent kafka topic create onchainsentinel.behavior.enriched
confluent kafka topic create onchainsentinel.risk.scores
```

# Start Flink SQL shell
```
confluent flink sql \
  --compute-pool <pool-id> \
  --cluster <lkc-id>
```

# Create tables
```
-- Raw event stream: features produced by your on-chain sampler / datagen
CREATE TABLE behavior_raw (
  address      STRING,
  chain        STRING,
  feature_json STRING,      -- serialized features from upstream
  ts           TIMESTAMP_LTZ(3),
  WATERMARK FOR ts AS ts
) WITH (
  'connector'   = 'confluent',
  'topic'       = 'onchainsentinel.behavior.raw',
  'value.format'= 'json_sr'
);

-- Enriched/aggregated text prompt we’ll send to Gemma
CREATE TABLE behavior_prompt (
  address      STRING,
  chain        STRING,
  prompt       STRING,
  ts           TIMESTAMP_LTZ(3),
  WATERMARK FOR ts AS ts
) WITH (
  'connector'   = 'confluent',
  'topic'       = 'onchainsentinel.behavior.enriched',
  'value.format'= 'json_sr'
);

-- Output topic with AI classification
CREATE TABLE risk_scores (
  address       STRING,
  chain         STRING,
  ts            TIMESTAMP_LTZ(3),
  model_name    STRING,
  response_text STRING
) WITH (
  'connector'   = 'confluent',
  'topic'       = 'onchainsentinel.risk.scores',
  'value.format'= 'json_sr'
);
```

# Build the prompt in Flink (behaviour → text)

You can either pre-build the prompt in a producer, or derive it via Flink.

```
INSERT INTO behavior_prompt
SELECT
  address,
  chain,
  CONCAT(
    'You are an AI model specialized in detecting blockchain fraud. ',
    'Analyze the following behavior for address ', address, ' on chain ', chain, '. ',
    'Behavior JSON: ', feature_json, '. ',
    'Classify the address as SAFE or SUSPICIOUS and briefly explain why.'
  ) AS prompt,
  ts
FROM behavior_raw;

```

This keeps all “behavior → explanation” logic inside the streaming pipeline, which is exactly what Confluent’s “AI on data in motion” story is about.

# Create the managed Gemma model in Flink

```
CREATE MODEL `onchainsentinel_gemma`
INPUT (text STRING)
OUTPUT (response STRING)
WITH (
  'provider'        = 'confluent',
  'task'            = 'classification',
  'confluent.model' = 'google/gemma-2-2b-it',
  'confluent.params.temperature' = '0.1',
  'confluent.params.max_tokens'  = '256'
);

```

# Use AI_COMPLETE to do in-stream GenAI

```
INSERT INTO risk_scores
SELECT
  p.address,
  p.chain,
  p.ts,
  'google/gemma-2-2b-it' AS model_name,
  response                AS response_text
FROM behavior_prompt AS p,
LATERAL TABLE(
  AI_COMPLETE('`onchainsentinel_gemma`', p.prompt)
);
```

# Get data in and out (CLI + connectors)




