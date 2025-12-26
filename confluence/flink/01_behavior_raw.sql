CREATE TABLE behavior_raw (
  address STRING,
  chain STRING,
  feature_json STRING,
  ts TIMESTAMP_LTZ(3),
  WATERMARK FOR ts AS ts
) WITH (
  'connector' = 'confluent',
  'topic' = 'onchainsentinel.behavior.raw',
  'value.format' = 'json_sr'
);
