from flask import Flask, jsonify
from flask_cors import CORS
from google.cloud import bigquery

app = Flask(__name__)
CORS(app)  # enable CORS globally

bq = bigquery.Client()

###########################################
# GET RISK FOR A SPECIFIC TRANSACTION
###########################################
@app.get("/risk/tx/<tx_id>")
def get_tx_risk(tx_id):
    query = """
        SELECT tx_id, address, chain, risk, reason
        FROM `true-gem.tx_risk.onchainsentinel_risk_tx`
        WHERE tx_id = @tx_id
        LIMIT 1
    """
    job = bq.query(query, job_config=bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("tx_id", "STRING", tx_id)]
    ))

    rows = list(job.result())
    if rows:
        row = rows[0]
        return jsonify({
            "tx_id": row.tx_id,
            "address": row.address,
            "chain": row.chain,
            "risk": row.risk,
            "reason": row.reason
        })

    return jsonify({
        "tx_id": tx_id,
        "risk": "UNKNOWN",
        "reason": "No record found"
    })


###########################################
# GET ADDRESS RISK + ALL TX FOR THAT ADDRESS
###########################################
@app.get("/risk/address/<address>")
def get_address_risk(address):
    # get aggregated risk summary
    risk_query = """
        SELECT
            address,
            MAX(risk) AS highest_risk,
            ARRAY_AGG(reason ORDER BY tx_id DESC LIMIT 1)[OFFSET(0)] AS latest_reason
        FROM `true-gem.tx_risk.onchainsentinel_risk_tx`
        WHERE address = @address
        GROUP BY address
        LIMIT 1
    """

    risk_job = bq.query(risk_query, job_config=bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("address", "STRING", address)]
    ))
    risk_rows = list(risk_job.result())

    # fetch transactions for the address
    tx_query = """
        SELECT tx_id, chain, risk, reason, origin_tx
        FROM `true-gem.tx_risk.onchainsentinel_risk_tx`
        WHERE address = @address
        ORDER BY tx_id DESC
    """
    tx_job = bq.query(tx_query, job_config=bigquery.QueryJobConfig(
        query_parameters=[bigquery.ScalarQueryParameter("address", "STRING", address)]
    ))

    tx_list = [
        {
            "tx_id": row.tx_id,
            "chain": row.chain,
            "risk": row.risk,
            "reason": row.reason,
            "origin_tx": row.origin_tx
        }
        for row in tx_job.result()
    ]

    if risk_rows:
        risk_row = risk_rows[0]
        return jsonify({
            "address": risk_row.address,
            "highest_risk": risk_row.highest_risk,
            "latest_reason": risk_row.latest_reason,
            "tx_count": len(tx_list),
            "transactions": tx_list
        })

    # no record found for that address
    return jsonify({
        "address": address,
        "highest_risk": "UNKNOWN",
        "latest_reason": "No flagged transactions found",
        "tx_count": 0,
        "transactions": []
    })


###########################################
# ROOT ENDPOINT FOR HEALTHCHECK
###########################################
@app.get("/")
def index():
    return jsonify({"status": "ok", "service": "OnChainSentinel Risk API"})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
