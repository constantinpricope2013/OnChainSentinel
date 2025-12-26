INSERT INTO behavior_scored
SELECT
  address,
  ML_HTTP_POST(
    'https://genai-service-xxxx.a.run.app/classify',
    MAP['features', CAST(features AS STRING)]
  ) AS risk,
  CURRENT_TIMESTAMP
FROM behavior_raw;
