
## Table of Contents
- [Notes](#notes)
- ➕ [Create BigQuery](#-create-bigquery)
- ✗  [Release BigQuery](#--release-bigquery) 


## Notes
1. We use BigQuery Sink V2 to connect to BigQuery
2. Replace tru-gem with your project name




## ➕ Create BigQuery

1. Create BigQuery dataset (gcloud)

```
gcloud config set project true-gem

```


2. Create a BigQuery service account + key
```
gcloud iam service-accounts create bq-sink-writer \
    --display-name="BigQuery Sink Writer"

gcloud projects add-iam-policy-binding true-gem \
    --member="serviceAccount:bq-sink-writer@true-gem.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding true-gem \
    --member="serviceAccount:bq-sink-writer@true-gem.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"

```


Generate the JSON key (required by the connector):
```
gcloud iam service-accounts keys create bq-sink-writer.json \
    --iam-account="bq-sink-writer@true-gem.iam.gserviceaccount.com"

```

3. Upload the JSON key into Confluent as a secret
```
confluent secret file create bq-sink-writer.json --name bq-writer-key
```

4. Create dataset
```
bq --location=US mk tx_risk
```


5. Create table within dataset
```
bq mk --table tx_risk.onchainsentinel_risk_tx \
address:STRING,tx_id:STRING,chain:STRING,model_name:STRING,origin_tx:STRING,risk:STRING,reason:STRING

```


List tables in dataset
```
bq ls tx_risk
```


## ✗  Release BigQuery


1. Delete the BigQuery table

```
bq rm -f -t tx_risk.onchainsentinel_risk_tx

```

2. Delete the BigQuery dataset
```
bq rm -f -d tx_risk
```

3. Remove the IAM bindings
```
gcloud projects remove-iam-policy-binding true-gem \
  --member="serviceAccount:bq-sink-writer@true-gem.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataEditor"

gcloud projects remove-iam-policy-binding true-gem \
  --member="serviceAccount:bq-sink-writer@true-gem.iam.gserviceaccount.com" \
  --role="roles/bigquery.jobUser"

```

4. Delete the service account
gcloud iam service-accounts delete \
  bq-sink-writer@true-gem.iam.gserviceaccount.com \
  --quiet

5. Delete the service account key (local)
rm bq-sink-writer.json



