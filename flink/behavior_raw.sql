CREATE TABLE behavior_raw (
  address STRING,
  chain STRING,
  features MAP<STRING, DOUBLE>,
  `timestamp` TIMESTAMP(3)
) WITH (
  'connector' = 'confluent',
  'topic' = 'behavior.raw',
  'value.format' = 'json',
  'value.json.fail-on-missing-field' = 'false'
);
