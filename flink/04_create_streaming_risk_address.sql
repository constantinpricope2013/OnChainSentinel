INSERT INTO onchainsentinel_risk_address
SELECT
    CAST(address AS BYTES) AS key,
    address,
    chain,
    model_name,
    MAX(risk) AS risk,
    CONCAT(
        'Some of the transactions made by this address were flagged due to: \n',
        ARRAY_JOIN(ARRAY_AGG(reason), '\n ')
    ) AS reason
FROM onchainsentinel_risk_tx
GROUP BY address, chain, model_name;
