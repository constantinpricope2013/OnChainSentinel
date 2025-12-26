from confluent_kafka import Producer
import json, time

BOOTSTRAP = "<bootstrap>"
API_KEY   = "<key>"
API_SECRET= "<secret>"

p = Producer({
    'bootstrap.servers': BOOTSTRAP,
    'security.protocol':'SASL_SSL',
    'sasl.mechanisms':'PLAIN',
    'sasl.username':API_KEY,
    'sasl.password':API_SECRET
})

payload = {
  "address": "0xTEST",
  "chain": "ethereum",
  "feature_json": json.dumps({"burstiness":0.92, "out_in_ratio":0.88}),
  "ts": int(time.time()*1000)
}

p.produce("onchainsentinel.behavior.raw", json.dumps(payload).encode("utf-8"))
p.flush()
print("Sent test event.")

