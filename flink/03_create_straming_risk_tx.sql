
INSERT INTO onchainsentinel_risk_tx
SELECT
    CAST(txId AS BYTES) AS key,
    address,
    txId as tx_id,
    chain,
    'model_tx_analyzer' AS model_name,
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    ) AS origin_tx,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.risk_level'
    ) AS risk,
    JSON_VALUE(
      REPLACE(REPLACE(json_result, '```json', ''), '```', ''),
      '$.reason'
    ) AS reason
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT(
    'model_tx_analyzer',
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    )
  )
);

