

# ᯓ★ Deploy risk api cloud run

```
gcloud auth login
gcloud config set project true-gem
```

```
gcloud run deploy tx-risk-api \
    --source . \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated
```



## ✗ Release resource
gcloud run services delete tx-risk-api

