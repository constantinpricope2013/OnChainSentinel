

Note:
We use BigQuery Sink V2 to connect to BigQuery


1. Create BigQuery dataset (gcloud)


```
gcloud config set project YOUR_GCP_PROJECT_ID

gcloud bigquery datasets create onchainsentinel \
    --location=US \
    --description="OnChainSentinel risk sink dataset"

```


2. Create a BigQuery service account + key
```
gcloud iam service-accounts create bq-sink-writer \
    --display-name="BigQuery Sink Writer"

gcloud projects add-iam-policy-binding YOUR_GCP_PROJECT_ID \
    --member="serviceAccount:bq-sink-writer@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding YOUR_GCP_PROJECT_ID \
    --member="serviceAccount:bq-sink-writer@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"

```


Generate the JSON key (required by the connector):
```
gcloud iam service-accounts keys create bq-sink-writer.json \
    --iam-account="bq-sink-writer@YOUR_GCP_PROJECT_ID.iam.gserviceaccount.com"

```

3. Upload the JSON key into Confluent as a secret
```
confluent secret file create bq-sink-writer.json --name bq-writer-key
```

4. Create dataset
```
bq --location=US mk tx_risk
```


5.
```
bq mk --table tx_risk.onchainsentinel_risk_tx \
address:STRING,tx_id:STRING,chain:STRING,model_name:STRING,origin_tx:STRING,risk:STRING,reason:STRING

```


List tables in dataset
```
bq ls tx_risk
```



