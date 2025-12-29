

![logo-light](assets/logo-light-smaller.png#gh-light-mode-only)
![logo-dark](assets/logo-dark-smaller.png#gh-dark-mode-only)


## Table of Contents
1. 📝 [Description](#-description)
2. ✏️ [Architecture](#%EF%B8%8F-architecture)
3. 🧩 [Proof of concept](#-proof-of-concept)
4. 🛠️ [Setup](#%EF%B8%8F-setup)
5. 🚀 [Deploy](#-deploy)
   - [a. Create resources in Confluent Cloud](#create-resources-in-confluent-cloud)
   - [b. Create Gemini Key](#create-key-gemini)
   - [c. Create Streamning in Flink](#create-streaming-in-flink)
   - [d. Create BigQuery in GCP](#create-bigquery-in-gcp)
   - [e. Create BigQuery sink in Conflunt Web](#create-bigquery-sink-in-conflunt-web)
   - [f. Deploy CloudRun risk_api ](#deploy-cloudrun-risk_api)
6. 💣 [Destroy](#-destroy)
   - [Destroy Resource Confluent Cloud](#destroy-resource-confluent-cloud)
   - [Destroy Resource GCP](#destroy-resource-gcp)
     - ⛃ [Destroy BigQuery](#-destroy-bigquery)
7. 🧪 [End to end test](#-end-to-end-test)

## 📝 Description
This repository contains a minimal Proof of Concept demonstrating:
- Real-time behavior ingestion (Kafka)
- Risk assesment through Gemini API remote model

## ✏️ Architecture
![arhitecture-light](assets/arhitecture-light.png#gh-light-mode-only)
![arhitecture-dark](assets/arhitecture-dark.png#gh-dark-mode-only)


---

## 🧩 Proof of concept
![poc-light](assets/poc-light.png#gh-light-mode-only)
![poc-dark](assets/poc-dark.png#gh-dark-mode-only)


---


## 🛠️ SETUP

For this project we use confluent and google cloud (gcloud) cli.

As components we use:
1. Confluent Cloud 
 - Kafka 
 - Flink AI
2. Google Cloud Platform 
  - Gemini API exposure
  - Cloud Run
  - BigQuery

Extra details:
 We created schemas, logo using draw.io (Check ./assets/OnChainSentinel.drawio)


## 🚀 Deploy

Here will make in steps as we need to deploy in both Google Cloud and Confluent Cloud

### Create resources in Confluent Cloud

For simplicity we created scripts:
1. Deploy resources on Clonfluent Cloud using [deploy script](deploy.sh)
```sh
deploy.sh 
```
2. Wait for Kafka to be up


3. Create topics using [create topic script](kafka/create_topics.sh)
```sh
kafka/create_topics.sh
```

4. Create schemas using [create schemas script](kafka/create_schemas.sh)
```sh
kafka/create_schemas.sh
```

For more info regarding the above and all CONFLUNET operation check the [CONFLUENT read me file](README_CONFLUENT.md)

### Create key Gemini
Access the website https://aistudio.google.com/app/api-keys and create a new key


### Create streaming in Flink
Create in Flink Shell the remote model along with streaming pipeline, check details in [Flink read me file](flink/README.md) 

All we need is up, we just need to create also a sink with BiqQuery but first we will need to have already deploy BigQuery and the credential available to us.

### Create BigQuery in GCP
Please check the [BigQuery read me file](sink-bigquery/README.md)

### Create BigQuery sink in Conflunt Web
Please install BigQuery sink v2 using previously generated credential using the web interface

### Deploy CloudRun risk_api 
Please check the [CloudRun risk-api read me file](api/README.md)


## 💣 Destroy

We have two components that we must destroy resources

### Destroy Resource Confluent Cloud
We can simply call that just deletes the environment and all the resources will be deleted.
```
destroy.sh
```

### Destroy Resource GCP

#### ⛃ Destroy BigQuery 
```

```

#### 🔑 Destroy API Key from AI Studio
Access the website https://aistudio.google.com/app/api-keys and delete key from your account


---

## 🧪 END TO END TEST

The flow is:
1. producer script inserts 3 messages in onchainsentinel_tx topic
2. flink streaming reads from topic, pings the gemini for risk assesment and saves the result in onchainsentinel_risk_tx
3. BigQuery Sink v2 reads from onchainsentinel_risk_tx topic and enters the data in BigQuery
4. The cloud run risk-api each time is called reads from the BigQuery and returns the result
5. The dashboard calls the API 


### Run producer once

We have a script that inserts into onchainsentinel_tx topic 3 messages which are 3 transactions exampl from eth mainnet


```
producer.sh
```