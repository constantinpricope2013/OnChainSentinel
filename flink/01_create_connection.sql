CREATE CONNECTION googleai_connection
WITH (
  'type' = 'googleai',
  'endpoint' = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash:generateContent',
  'api-key' = '<your-gcp-api-key>'
);