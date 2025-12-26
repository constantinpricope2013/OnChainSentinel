# OnChainSentinel – Real-Time Blockchain Fraud Behavior Detection

OnChainSentinel continuously analyzes blockchain behavioral features in real time, classifies address risk with GenAI,
and exposes results through a public API.

Architecture:

1. Produce behavior to Kafka topic `behavior.raw`
2. Confluent Cloud Flink enriches data using GenAI (`Vertex AI`)
3. Result is streamed to `behavior.scored`
4. MongoDB sink materializes results
5. Cloud Run API exposes risk classification

Aligned with:
- https://github.com/confluentinc/gcp-flink-cflt-genai-quickstart
- https://github.com/confluentinc/mongodb-cflt-gcp-genai-quickstart

---

## RUNNING END-TO-END

### 0 — Dependencies

```
gcloud components install beta
pip install google-cloud-aiplatform vertexai flask pymongo confluent-kafka
```

### 1 — Configure Google Cloud

```
gcloud auth login
gcloud config set project YOUR_PROJECT
gcloud services enable aiplatform.googleapis.com run.googleapis.com
```


### 2 — Confluent Cloud CLI setup

```
confluent login
confluent environment use <ENV_ID>
confluent kafka cluster use <CLUSTER_ID>

```

### 3 — Create Topics
```
bash kafka/topics.sh
```


### 4 — Deploy Flink SQL
Upload files inside `flink/` into Confluent → Flink SQL Workspace:

- behavior_raw.sql
- behavior_scored.sql
- genai_stream_job.sql

### 5 — Deploy GenAI enrichment service to Cloud Run

```
cd genai
gcloud run deploy genai-service --source . --region us-central1 --allow-unauthenticated

```

Take note of the deployed URL, use it inside `genai_stream_job.sql`.

### 6 — Setup MongoDB sink

```
confluent connect create --config sink/mongo_sink.json

```

### 7 — Deploy API to Cloud Run

```
cd api
gcloud run deploy onchainsentinel-api --source . --region us-central1 --allow-unauthenticated
```

### 8 — Run a test round


```
confluent kafka topic produce behavior.raw < kafka/sample-input.json
curl https://onchainsentinel-api-xxxx.a.run.app/address/0xTEST

```
Output
→ {"address":"0xTEST","risk":"DANGER"}



