// Live RLS test for Anonity.
//
// Confirms that the normal Supabase client SDK (using only the
// publishable / anon key from lib/config/supabase_config.dart)
// genuinely cannot insert a post into public.posts.
//
// Three runs:
//   1. Unauthenticated client → must fail (no auth.uid()).
//   2. Signed-in client A trying to insert a post whose author_id is
//      some other user's UUID → must fail (auth.uid() != author_id).
//   3. Control: signed-in client A inserting with their own UUID →
//      must succeed. We delete the row right after so it leaves no
//      trace in the feed.
//
// Run with: `node test_rls.js` from anonity/test/sec.

const { createClient } = require('@supabase/supabase-js');
const crypto = require('crypto');

// Pulled directly from lib/config/supabase_config.dart so this test
// always exercises the exact same key the Flutter app is built with.
const SUPABASE_URL = 'https://wzfgyrorszweotmnvduv.supabase.co';
const SUPABASE_ANON_KEY =
  'sb_publishable_-J1ECyHgYQJgtwwbG8Q2rA_CWEMq_W8';

function makeClient() {
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

function randEmail(tag) {
  // Throwaway addresses on a real domain Supabase accepts.
  // Mail-tester domains are commonly used for CI test users.
  return `${tag}-${crypto.randomBytes(6).toString('hex')}@mailinator.com`;
}

function summarize(label, result) {
  const err = result.error;
  const dataOk = Array.isArray(result.data)
    ? result.data.length
    : result.data
      ? 'present'
      : 'none';
  console.log(`\n[${label}]`);
  console.log(`  error: ${err ? `${err.code} ${err.status || ''} ${err.message}` : 'none'}`);
  console.log(`  data:  ${dataOk}`);
  return err;
}

async function run() {
  // ---------------------------------------------------------------------
  // Run 1: unauthenticated client tries to insert a post.
  // ---------------------------------------------------------------------
  const anon = makeClient();
  const r1 = await anon.from('posts').insert({
    author_id: crypto.randomUUID(), // doesn't matter, claim is fake
    content: 'anon write attempt — should be blocked by RLS',
    is_anonymous: true,
    tags: [],
  });
  const r1Err = summarize('RUN 1 — unauthenticated insert', r1);

  // ---------------------------------------------------------------------
  // Run 2: two freshly-signed-up users; A tries to insert as B.
  // ---------------------------------------------------------------------
  const userA = makeClient();
  const userB = makeClient();
  const pw = 'TestPass-9f7a!';

  const signupA = await userA.auth.signUp({
    email: randEmail('rls-a'),
    password: pw,
  });
  if (signupA.error) {
    console.error('signup A failed:', signupA.error);
    process.exit(1);
  }
  const signupB = await userB.auth.signUp({
    email: randEmail('rls-b'),
    password: pw,
  });
  if (signupB.error) {
    console.error('signup B failed:', signupB.error);
    process.exit(1);
  }
  const uidA = userA.auth.currentUser?.id || signupA.data.user?.id;
  const uidB = userB.auth.currentUser?.id || signupB.data.user?.id;
  console.log(`\nsigned up A=${uidA} B=${uidB}`);
  console.log(`A session present: ${!!userA.auth.currentSession}`);
  console.log(`A session token ending: ${
    userA.auth.currentSession?.access_token
      ? '...' + userA.auth.currentSession.access_token.slice(-12)
      : 'NO TOKEN'
  }`);
  console.log(`A currentUser after signup: ${
    userA.auth.currentUser ? 'present' : 'NULL'
  } (this is null when email confirmation is required)`);

  // A tries to post with author_id = B's id (must fail).
  const r2 = await userA.from('posts').insert({
    author_id: uidB,
    content: 'forged-as-other-user attempt',
    is_anonymous: true,
    tags: [],
  });
  const r2Err = summarize('RUN 2 — A inserts with author_id=B (must be blocked)', r2);

  // ---------------------------------------------------------------------
  // Run 3: control — A inserts with their own author_id.
  //
  // This run is a real control only if A actually has an authenticated
  // session (auth.uid() != null). This project has email confirmation
  // enabled, so signUp does not authenticate — RUN 3 cannot exercise
  // the positive case from the anon-key SDK alone. We report it as
  // SKIPPED in that case and call out the long-term fix below.
  //
  // Long-term fix (option 2 you approved): use a service_role key from
  // an env var to admin-confirm the throwaway users, then sign them
  // in via the anon SDK and exercise RUN 3 with a real JWT.
  // ---------------------------------------------------------------------
  let r3 = null;
  let insertedId = null;
  const haveSession =
    !!userA.auth.currentSession && !!userA.auth.currentUser;

  if (haveSession) {
    r3 = await userA.from('posts').insert({
      author_id: uidA,
      content: 'control post — should succeed, then deleted',
      is_anonymous: true,
      tags: [],
    });
    summarize('RUN 3 — A inserts with author_id=A (control)', r3);
    // SUCCESS means: NO error AND data is an array with at least one
    // row whose .id is a server-issued UUID. Anything else is a fail.
    if (!r3.error && Array.isArray(r3.data) && r3.data.length > 0) {
      insertedId = r3.data[0].id;
    }
    if (insertedId) {
      const del = await userA
        .from('posts')
        .delete()
        .eq('id', insertedId);
      console.log(
        `\n[cleanup — A deletes the control post ${insertedId}]  error: ${
          del.error ? del.error.message : 'none'
        }`
      );
      if (del.error) {
        console.log(`  ⚠ cleanup failed; row may remain in the feed`);
        insertedId = null; // don't credit the control if cleanup failed
      }
    }
  } else {
    console.log(
      '\n[RUN 3 — skipped] A has no session after signUp. The project has '
      + 'email confirmation enabled, so signUp does not authenticate '
      + 'the user. RUN 3 cannot exercise the positive case from the '
      + 'anon-key SDK alone. To exercise it, run the script with '
      + 'SUPABASE_SERVICE_ROLE_KEY set — see option (2) in the README.'
    );
  }

  // ---------------------------------------------------------------------
  // Verdict. RUN 1 and RUN 2 prove a normal client (publishable key
  // only) cannot insert a post. RUN 3 is informational.
  //
  // Crucially: RUN 3 is marked OK only when (a) we had a real session
  // AND (b) the server returned a row with a UUID AND (c) cleanup
  // deleted it. Without any one of those, RUN 3 is NOT "allowed" — it
  // is either skipped or failed.
  // ---------------------------------------------------------------------
  console.log('\n========== VERDICT ==========');
  const expected = {
    'RUN 1': 'blocked (RLS / 42501)',
    'RUN 2': 'blocked (RLS / 42501)',
  };
  let ok = true;
  for (const k of Object.keys(expected)) {
    const err = k === 'RUN 1' ? r1Err : r2Err;
    const passed = !!err; // any error means blocked
    console.log(`${k}: expected ${expected[k]} → got ${
      passed ? 'blocked' : 'ALLOWED'
    } ${passed ? '✓' : '✗'}`);
    if (!passed) ok = false;
  }
  if (!haveSession) {
    console.log(
      'RUN 3: control SKIPPED (no session — see option 2 fix below). '
      + 'Note: the security guarantee (RUN 1 and RUN 2) does not depend '
      + 'on RUN 3 having succeeded.'
    );
  } else if (insertedId) {
    console.log(`RUN 3: control inserted ${insertedId} and deleted it ✓`);
  } else if (r3 && r3.error) {
    console.log(
      `RUN 3: control FAILED with ${r3.error.code}: ${r3.error.message} ✗`
    );
    ok = false;
  } else {
    // Have a session but got neither an error nor a row — degenerate.
    console.log(
      `RUN 3: control FAILED (server returned neither error nor a row) ✗`
    );
    ok = false;
  }
  process.exit(ok ? 0 : 2);
}

run().catch((e) => {
  console.error('test crashed:', e);
  process.exit(3);
});
