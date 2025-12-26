INSERT INTO risk_scores
SELECT
  p.address,
  p.chain,
  p.ts,
  'google/gemma-2-2b-it',
  response
FROM behavior_prompt AS p,
LATERAL TABLE (
  AI_COMPLETE('`onchainsentinel_gemma`', p.prompt)
);
