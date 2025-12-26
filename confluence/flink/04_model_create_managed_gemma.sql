CREATE MODEL onchainsentinel_gemma
INPUT (text STRING)
OUTPUT (response STRING)
WITH (
  'provider'        = 'confluent',
  'task'            = 'classification',
  'confluent.model' = 'google/gemma-2-2b-it',
  'confluent.params.temperature'='0.1',
  'confluent.params.max_tokens'='256'
);
