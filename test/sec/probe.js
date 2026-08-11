// Probe: what does supabase-js actually return from an insert that
// the server rejects with RLS? Used to verify the script's behavior
// when RUN 3 has no session.
//
// Run: `node probe.js`

const { createClient } = require('@supabase/supabase-js');

const URL = 'https://wzfgyrorszweotmnvduv.supabase.co';
const KEY = 'sb_publishable_-J1ECyHgYQJgtwwbG8Q2rA_CWEMq_W8';

const anon = createClient(URL, KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});

(async () => {
  // Deliberately trigger RLS — no session, fake UUID.
  const res = await anon.from('posts').insert({
    author_id: '00000000-0000-0000-0000-000000000000',
    content: 'probe — what shape does an RLS rejection have?',
    is_anonymous: true,
    tags: [],
  });

  console.log('typeof res:', typeof res);
  console.log('Object.keys(res):', Object.keys(res));
  console.log('res.error:', res.error);
  console.log('res.error?.code:', res.error?.code);
  console.log('res.error?.message:', res.error?.message);
  console.log('res.error?.status:', res.error?.status);
  console.log('res.data:', res.data);
  console.log('res.status:', res.status);
  console.log('res.statusText:', res.statusText);
  console.log('res.count:', res.count);
})();
