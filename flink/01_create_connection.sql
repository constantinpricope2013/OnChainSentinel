CREATE CONNECTION googleai_connection
WITH (
  'type' = 'googleai',
  'endpoint' = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
  'api-key' = '<your-gcp-api-key>'
);