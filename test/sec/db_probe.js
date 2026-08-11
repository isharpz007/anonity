// db_probe.js — look for leftover test rows in public.posts.
//
// `posts_select` is using (true), so the anon/publishable key can read
// from this table. We look for the exact content strings the
// test_rls.js script would have inserted on each run.
//
// Run: `node db_probe.js` from anonity/test/sec.

const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = 'https://wzfgyrorszweotmnvduv.supabase.co';
const SUPABASE_ANON_KEY =
  'sb_publishable_-J1ECyHgYQJgtwwbG8Q2rA_CWEMq_W8';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});

(async () => {
  const probes = [
    { label: 'RUN 3 control',  pattern: '%control post%' },
    { label: 'RUN 1 attempt',  pattern: '%anon write attempt%' },
    { label: 'RUN 2 forgery',  pattern: '%forged-as-other-user%' },
  ];

  for (const { label, pattern } of probes) {
    const { data, error } = await supabase
      .from('posts')
      .select('id, author_id, content, created_at')
      .ilike('content', pattern)
      .order('created_at', { ascending: false })
      .limit(10);
    console.log(`--- ${label}  (ilike '${pattern}') ---`);
    if (error) {
      console.log('  error:', error.message);
    } else if (!data || data.length === 0) {
      console.log('  rows: (none)');
    } else {
      console.log(`  rows: ${data.length}`);
      for (const row of data) {
        console.log(`    id=${row.id}`);
        console.log(`    author_id=${row.author_id}`);
        console.log(`    content=${JSON.stringify(row.content)}`);
        console.log(`    created_at=${row.created_at}`);
      }
    }
  }
})();
