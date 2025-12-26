CREATE TABLE risk_scores (
  address STRING,
  chain STRING,
  ts TIMESTAMP_LTZ(3),
  model_name STRING,
  response_text STRING
) WITH (
  'connector' = 'confluent',
  'topic' = 'onchainsentinel.risk.scores',
  'value.format' = 'json_sr'
);
