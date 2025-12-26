from confluent_kafka import Producer
import json, time, random

p = Producer({'bootstrap.servers': '<bootstrap>',
              'security.protocol': 'SASL_SSL',
              'sasl.mechanisms': 'PLAIN',
              'sasl.username': '<api_key>',
              'sasl.password': '<api_secret>'})

def send_event(addr, chain):
    features = {
        "tx_count_24h": random.randint(1, 200),
        "unique_counterparties_7d": random.randint(1, 50),
        "dex_ratio": random.random(),
        "nft_mint_ratio": random.random(),
    }
    payload = {
        "address": addr,
        "chain": chain,
        "feature_json": json.dumps(features),
        "ts": int(time.time() * 1000)
    }
    p.produce("onchainsentinel.behavior.raw", json.dumps(payload).encode("utf-8"))
    p.flush()


