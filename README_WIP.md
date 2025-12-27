
# model creation


SELECT
    JSON_VALUE(json_result, '$.risk_level') AS risk_level,
    JSON_VALUE(json_result, '$.reason')     AS reason
FROM
(
    SELECT model_tx_analyzer(
        CONCAT(
          '{ "chain":"', chain,
          '", "txId":"', txId,
          '", "address":"', address,
          '", "toAddress":"', to_address,
          '", "amount":"', amount,
          '", "ts":"', ts,
          '" }'
        )
    ) AS json_result
    FROM onchainsentinel_tx
);



SHOW CATALOGS;
USE CATALOG onchainsentinel;


USE onchainsentinel-kafka;


SELECT
  JSON_VALUE(json_result, '$.risk_level') AS risk_level,
  JSON_VALUE(json_result, '$.reason')     AS reason
FROM (
    SELECT model_tx_analyzer(
        CAST(
            CONCAT(
              '{ "chain":"', chain,
              '", "txId":"', txId,
              '", "address":"', address,
              '", "toAddress":"', to_address,
              '", "amount":"', amount,
              '", "ts":"', ts,
              '" }'
            ) AS STRING
        )
    ) AS json_result
    FROM onchainsentinel_tx
);


---

    SELECT model_tx_analyzer(
        CAST(
            CONCAT(
              '{ "chain":"', chain,
              '", "txId":"', txId,
              '", "address":"', address,
              '", "toAddress":"', to_address,
              '", "amount":"', amount,
              '", "ts":"', ts,
              '" }'
            ) AS STRING
        )
    ) AS json_result
    FROM onchainsentinel_tx

---

    SELECT 
        CAST(
            CONCAT(
              '{ "chain":"', chain,
              '", "txId":"', txId,
              '", "address":"', address,
              '", "toAddress":"', to_address,
              '", "amount":"', amount,
              '", "ts":"', ts,
              '" }'
            ) AS STRING
        )
     AS json_result
    FROM onchainsentinel_tx

---

SELECT * FROM
    ML_PREDICT(
      TABLE raw_data,
      MODEL 'model_tx_analyzer',
      DESCRIPTOR(
        SELECT
        CONCAT(
          '{ "chain":"', chain,
          '", "txId":"', txId,
          '", "address":"', address,
          '", "to_address":"', to_address,
          '", "amount":"', amount,
          '", "ts":"', ts,
          '" }'
        ) AS tx_payload
      FROM onchainsentinel_tx;
      )
    );

----
  SELECT 
    txId,
    chain,
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    ) AS json_tx
FROM onchainsentinel_tx_,
LATERAL TABLE(ML_PREDICT('model_tx_analyzer', json_tx));

---
SELECT
    txId,
    chain,
    json_result
FROM ML_PREDICT(
    TABLE (
        SELECT
            txId,
            chain,
            CONCAT(
              '{ "chain":"', chain,
              '", "txId":"', txId,
              '", "address":"', address,
              '", "toAddress":"', to_address,
              '", "amount":"', amount,
              '", "ts":"', ts,
              '" }'
            ) AS tx_payload
        FROM onchainsentinel_tx
    ),
    MODEL 'model_tx_analyzer',
    DESCRIPTOR(tx_payload)
);

---






SELECT
    txId,
    chain,
    json_result
FROM TABLE(
    ML_PREDICT(
        TABLE (
            SELECT
                txId,
                chain,
                CONCAT(
                  '{ "chain":"', chain,
                  '", "txId":"', txId,
                  '", "address":"', address,
                  '", "toAddress":"', to_address,
                  '", "amount":"', amount,
                  '", "ts":"', ts,
                  '" }'
                ) AS tx_payload
            FROM onchainsentinel_tx
        ),
        MODEL 'model_tx_analyzer',
        DESCRIPTOR(tx_payload)
    )
);



----
  SELECT 
    *
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT('model_tx_analyzer', CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    )));







