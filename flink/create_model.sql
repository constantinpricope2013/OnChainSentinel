CREATE MODEL model_tx_analyzer
INPUT (`text` VARCHAR(2147483647))
OUTPUT (`output` VARCHAR(2147483647))
WITH (
  'googleai.connection' = 'googleai_connection',
  'googleai.system_prompt' = 'You are a blockchain AI risk classifier.\\nClassify the following transaction as HIGH, MEDIUM, or LOW risk',
  'provider' = 'googleai',
  'task' = 'text_generation'
);