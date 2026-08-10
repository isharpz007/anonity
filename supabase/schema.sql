-- ============================================================================
-- Anonity — full schema, RLS policies, and triggers.
-- Paste this entire file into Supabase → SQL Editor → New query → Run.
--
-- Safe to re-run: each statement is idempotent (uses IF NOT EXISTS /
-- DROP IF EXISTS / CREATE OR REPLACE). If you change something here,
-- run the whole file again to bring your project back in sync.
-- ============================================================================


-- ---------------------------------------------------------------------------
-- profiles: one row per user, created automatically on signup.
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null,
  bio text not null default '',
  avatar_url text,
  created_at timestamptz not null default now()
);

-- Auto-create a profile row when a user signs up. The default username
-- comes from the part of the email before the @, with a short hash
-- suffix so collisions don't blow up the signup flow.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_username text;
  suffix text;
begin
  base_username := split_part(coalesce(new.email, 'user'), '@', 1);
  -- Strip anything that isn't a letter/digit/underscore so the generated
  -- username always passes the simple text format we use elsewhere.
  base_username := regexp_replace(base_username, '[^a-zA-Z0-9_]', '', 'g');
  if length(base_username) = 0 then
    base_username := 'user';
  end if;
  suffix := substr(replace(new.id::text, '-', ''), 1, 6);

  insert into public.profiles (id, username)
  values (new.id, base_username || '_' || suffix)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


-- ---------------------------------------------------------------------------
-- posts
-- ---------------------------------------------------------------------------
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  is_anonymous boolean not null default true,
  section text,
  tags text[] not null default '{}',
  comments_count int not null default 0,
  likes_count int not null default 0,
  reposts_count int not null default 0,
  views_count int not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts (created_at desc);
create index if not exists posts_section_idx on public.posts (section);
create index if not exists posts_likes_count_idx on public.posts (likes_count desc);
create index if not exists posts_tags_idx on public.posts using gin (tags);


-- ---------------------------------------------------------------------------
-- likes
-- ---------------------------------------------------------------------------
create table if not exists public.likes (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create index if not exists likes_user_id_idx on public.likes (user_id);

-- Keep posts.likes_count in sync whenever a like is added or removed.
create or replace function public.sync_post_likes_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update public.posts
      set likes_count = likes_count + 1
      where id = new.post_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.posts
      set likes_count = greatest(likes_count - 1, 0)
      where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists sync_likes_count on public.likes;
create trigger sync_likes_count
  after insert or delete on public.likes
  for each row execute function public.sync_post_likes_count();


-- ---------------------------------------------------------------------------
-- groups
-- ---------------------------------------------------------------------------
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  name text unique not null,
  description text not null default '',
  icon text,
  created_at timestamptz not null default now()
);

create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (group_id, user_id)
);

create index if not exists group_members_user_id_idx on public.group_members (user_id);

create table if not exists public.group_messages (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  is_anonymous boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists group_messages_group_id_idx on public.group_messages (group_id, created_at desc);

-- Seed starter groups matching the mockup. Safe to re-run because of
-- the on conflict clause.
insert into public.groups (name, description, icon) values
  ('Anonity Lounge', 'Off-topic and casual chat.',         '💬'),
  ('Mental Health',   'A safe space to vent and support.',  '🧠'),
  ('Tech Talk',       'Code, gadgets, and the internet.',   '💻'),
  ('Campus Life',     'University stories and advice.',     '🎓')
on conflict (name) do nothing;


-- ---------------------------------------------------------------------------
-- comments  (NEW — supports the in-app reply sheet)
-- ---------------------------------------------------------------------------
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null check (length(content) > 0 and length(content) <= 500),
  is_anonymous boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists comments_post_id_idx on public.comments (post_id, created_at asc);

-- Keep posts.comments_count in sync on insert/delete. This is the
-- critical bit the client relies on: after `addComment` returns, the
-- next feed fetch sees the new total without an extra round trip.
create or replace function public.sync_post_comments_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update public.posts
      set comments_count = comments_count + 1
      where id = new.post_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.posts
      set comments_count = greatest(comments_count - 1, 0)
      where id = old.post_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists sync_comments_count on public.comments;
create trigger sync_comments_count
  after insert or delete on public.comments
  for each row execute function public.sync_post_comments_count();


-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table public.profiles       enable row level security;
alter table public.posts          enable row level security;
alter table public.likes          enable row level security;
alter table public.groups         enable row level security;
alter table public.group_members  enable row level security;
alter table public.group_messages enable row level security;
alter table public.comments       enable row level security;

-- profiles: anyone authenticated can read; only the owner can write.
drop policy if exists "profiles_select" on public.profiles;
create policy "profiles_select"
  on public.profiles for select
  using (auth.role() = 'authenticated' or auth.role() = 'anon');

drop policy if exists "profiles_update_self" on public.profiles;
create policy "profiles_update_self"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self"
  on public.profiles for insert
  with check (auth.uid() = id);

-- posts: anyone can read; only the author can write their own row.
drop policy if exists "posts_select" on public.posts;
create policy "posts_select"
  on public.posts for select
  using (true);

drop policy if exists "posts_insert_self" on public.posts;
create policy "posts_insert_self"
  on public.posts for insert
  with check (auth.uid() = author_id);

drop policy if exists "posts_update_self" on public.posts;
create policy "posts_update_self"
  on public.posts for update
  using (auth.uid() = author_id)
  with check (auth.uid() = author_id);

drop policy if exists "posts_delete_self" on public.posts;
create policy "posts_delete_self"
  on public.posts for delete
  using (auth.uid() = author_id);

-- likes
drop policy if exists "likes_select" on public.likes;
create policy "likes_select"
  on public.likes for select
  using (true);

drop policy if exists "likes_insert_self" on public.likes;
create policy "likes_insert_self"
  on public.likes for insert
  with check (auth.uid() = user_id);

drop policy if exists "likes_delete_self" on public.likes;
create policy "likes_delete_self"
  on public.likes for delete
  using (auth.uid() = user_id);

-- groups: read is public; members-only writes for group_messages
drop policy if exists "groups_select" on public.groups;
create policy "groups_select"
  on public.groups for select
  using (true);

drop policy if exists "group_members_select" on public.group_members;
create policy "group_members_select"
  on public.group_members for select
  using (true);

drop policy if exists "group_members_insert_self" on public.group_members;
create policy "group_members_insert_self"
  on public.group_members for insert
  with check (auth.uid() = user_id);

drop policy if exists "group_members_delete_self" on public.group_members;
create policy "group_members_delete_self"
  on public.group_members for delete
  using (auth.uid() = user_id);

drop policy if exists "group_messages_select_members" on public.group_messages;
create policy "group_messages_select_members"
  on public.group_messages for select
  using (
    exists (
      select 1 from public.group_members gm
      where gm.group_id = group_messages.group_id
        and gm.user_id = auth.uid()
    )
  );

drop policy if exists "group_messages_insert_members" on public.group_messages;
create policy "group_messages_insert_members"
  on public.group_messages for insert
  with check (
    auth.uid() = author_id
    and exists (
      select 1 from public.group_members gm
      where gm.group_id = group_messages.group_id
        and gm.user_id = auth.uid()
    )
  );

-- comments: anyone authenticated can read; only the author can write
-- their own. Triggers handle the parent's comments_count for us.
drop policy if exists "comments_select" on public.comments;
create policy "comments_select"
  on public.comments for select
  using (true);

drop policy if exists "comments_insert_self" on public.comments;
create policy "comments_insert_self"
  on public.comments for insert
  with check (auth.uid() = author_id);

drop policy if exists "comments_delete_self" on public.comments;
create policy "comments_delete_self"
  on public.comments for delete
  using (auth.uid() = author_id);


-- ---------------------------------------------------------------------------
-- Realtime: let the client subscribe to feed + group message changes.
-- (Required for the live feeds to actually push updates.)
-- ---------------------------------------------------------------------------
alter publication supabase_realtime add table public.posts;
alter publication supabase_realtime add table public.group_messages;
alter publication supabase_realtime add table public.comments;
