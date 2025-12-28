



```
SELECT
    txId,
    chain,
    address,
    to_address,
    amount,
    ts,
    JSON_VALUE(json_result, '$.risk_level') AS risk,
    JSON_VALUE(json_result, '$.reason')     AS reason
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
```

SELECT
    json_result
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
```


```
SELECT
    txId,
    chain,
    address,
    to_address,
    amount,
    ts,
    JSON_VALUE(
      REGEXP_REPLACE(json_result, r'\`\`\`json|\`\`\`', ''),
      '$.risk_level'
    ) AS risk,
    JSON_VALUE(
      REGEXP_REPLACE(json_result, r'\`\`\`json|\`\`\`', ''),
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

```



```
SELECT
    txId,
    chain,
    address,
    to_address,
    amount,
    ts,
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

```





