
# ⚠️ Issues we encounter during development 

1. Intrepretation of data from AI when we want two fields
- we needed the risk assesment (LOW, MEDIUM. HIGH) but also a short sentence to explain it
but the response was with custom json in markup language ```json ```

2. we could not use concat inside select as because it did not find the column 


PASS ✅
```
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
```

FAILED ❌
```
  SELECT 
    CONCAT(
      '{ "chain":"', chain,
      '", "txId":"', txId,
      '", "address":"', address,
      '", "toAddress":"', to_address,
      '", "amount":"', amount,
      '", "ts":"', ts,
      '" }'
    ) as tx_json
FROM onchainsentinel_tx,
LATERAL TABLE(ML_PREDICT('model_tx_analyzer', tx_json)); 
```
ℹ️ The error message said column tx_json not found 

3. Some errors from the shell were not well explained 

Error: can't fetch results. Statement phase is: FAILED
Error details: Internal error occurred. Statement:

Most likely you cannot create a view with an ML_PREDICT (Model integration) - you must check this



