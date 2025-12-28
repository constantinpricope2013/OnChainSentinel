

gcloud auth login
gcloud config set project true-gem


gcloud run deploy tx-risk-api \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated


gcloud run services delete tx-risk-api

