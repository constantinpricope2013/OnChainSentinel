CREATE TABLE behavior_scored (
  address STRING,
  risk STRING,
  scored_at TIMESTAMP(3)
) WITH (
  'connector' = 'confluent',
  'topic' = 'behavior.scored',
  'value.format' = 'json',
  'value.json.fail-on-missing-field' = 'false'
);
