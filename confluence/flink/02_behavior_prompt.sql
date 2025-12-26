CREATE TABLE behavior_prompt (
  address STRING,
  chain STRING,
  prompt STRING,
  ts TIMESTAMP_LTZ(3),
  WATERMARK FOR ts AS ts
) WITH (
  'connector' = 'confluent',
  'topic' = 'onchainsentinel.behavior.enriched',
  'value.format' = 'json_sr'
);

INSERT INTO behavior_prompt
SELECT
  address,
  chain,
  CONCAT(
    'You are an anti-fraud AI. ',
    'Classify address ', address, ' as SAFE or SUSPICIOUS.',
    ' Behavioral JSON: ', feature_json
  ),
  ts
FROM behavior_raw;
