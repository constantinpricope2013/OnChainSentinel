
-- Not working due to upsert
-- Error: can't fetch results. Statement phase is: FAILED
-- Error details: Table sink 'onchainsentinel.lkc-go56j1.onchainsentinel_risk_address' doesn't support consuming update changes which is produced by node GroupAggregate(groupBy=[address, chain, model_name], select=[address, chain, model_name, MAX(risk) AS risk, ARRAY_AGG(reason) AS $f4]



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
