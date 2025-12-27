CREATE MODEL model_tx_analyzer
INPUT (
    tx_payload STRING
)
OUTPUT (
    json_result STRING 
)
WITH (
  'googleai.connection' = 'googleai_connection',
  'googleai.system_prompt' = 'You are a blockchain fraud risk classifier. \
Evaluate raw transaction data using fraud behavioral or fraud patterns indicators. \
Respond ONLY with a JSON object containing "risk_level" and "reason". \
risk_level must be LOW, MEDIUM, or HIGH. reason must be a single short sentence.',
  'provider' = 'googleai',
  'task' = 'text_generation'
);
