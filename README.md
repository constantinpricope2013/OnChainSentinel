

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/logo-light.png">
  <img alt="OnChainSentinel Logo" src="assets/logo-light.png" width="300">
</picture>

## Table of Contents
- [📝 Description](#📝-description)
- [✏️ Architecture](#✏️-architecture)
- [🧩 Proof of concept](#🧩-proof-of-concept)
- [🛠️ Setup](#🛠️-setup)
- [🚀 Deploy](#🚀-deploy)
- [💣 Destroy](#💣-destroy)
- [🧪 End to end test](#🧪-end-to-end-test)

## 📝 Description
This repository contains a minimal Proof of Concept demonstrating:
- Real-time behavior ingestion (Kafka)
- Risk assesment through Gemini API remote model

## ✏️ Architecture
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/arhitecture-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/arhitecture-light.png">
  <img alt="OnChainSentinel Logo" src="assets/arhitecture-light.png" width="800">
</picture>

---

## 🧩 Proof of concept
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/poc-dark.png">
  <source media="(prefers-color-scheme: light)" srcset="assets/poc-light.png">
  <img alt="OnChainSentinel Logo" src="assets/poc-light.png" width="800">
</picture>

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


### Create BigQuery in GCP


### Deploy CloudRun risk_api 



## 💣 Destroy

We have two components that we must destroy resources

### Destroy Resource Confluent Cloud
We can simply call that just deletes the environment and all the resources will be deleted.
```
destroy.sh
```

### Destroy Resource GCP

---

## 🧪 END TO END TEST

### Run producer once
```
producer.sh
```