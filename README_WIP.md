
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






