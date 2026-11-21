-- =====================================================================
--  Hafiy Transport Agency website admin: database setup for Supabase
--  Run this ONCE: Supabase Dashboard > SQL Editor > New query > paste > Run
--  It is safe to run again (it will not delete existing data).
-- =====================================================================

-- 1) Tables ------------------------------------------------------------
create table if not exists public.site_content (
  key        text primary key,
  value      text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.gallery (
  id         bigint generated always as identity primary key,
  url        text not null,
  path       text,                       -- storage path (null for the built-in starter photos)
  caption    text default '',
  sort       int  not null default 0,
  created_at timestamptz not null default now()
);

-- who is allowed to edit (filled in step 3 below)
create table if not exists public.admins (
  user_id uuid primary key references auth.users(id) on delete cascade
);

-- 2) Security: everyone may READ content, only admins may WRITE ----------
alter table public.site_content enable row level security;
alter table public.gallery      enable row level security;
alter table public.admins       enable row level security;   -- no policies = nobody can read it directly

create or replace function public.is_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;
revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;

drop policy if exists "content: public read"   on public.site_content;
drop policy if exists "content: admin insert"  on public.site_content;
drop policy if exists "content: admin update"  on public.site_content;
drop policy if exists "content: admin delete"  on public.site_content;
create policy "content: public read"  on public.site_content for select using (true);
create policy "content: admin insert" on public.site_content for insert to authenticated with check (public.is_admin());
create policy "content: admin update" on public.site_content for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "content: admin delete" on public.site_content for delete to authenticated using (public.is_admin());

drop policy if exists "gallery: public read"   on public.gallery;
drop policy if exists "gallery: admin insert"  on public.gallery;
drop policy if exists "gallery: admin update"  on public.gallery;
drop policy if exists "gallery: admin delete"  on public.gallery;
create policy "gallery: public read"  on public.gallery for select using (true);
create policy "gallery: admin insert" on public.gallery for insert to authenticated with check (public.is_admin());
create policy "gallery: admin update" on public.gallery for update to authenticated using (public.is_admin()) with check (public.is_admin());
create policy "gallery: admin delete" on public.gallery for delete to authenticated using (public.is_admin());

-- 3) Photo storage bucket (public to view, admin-only to change) ---------
insert into storage.buckets (id, name, public)
values ('site-images', 'site-images', true)
on conflict (id) do nothing;

drop policy if exists "images: public read"  on storage.objects;
drop policy if exists "images: admin insert" on storage.objects;
drop policy if exists "images: admin update" on storage.objects;
drop policy if exists "images: admin delete" on storage.objects;
create policy "images: public read"  on storage.objects for select using (bucket_id = 'site-images');
create policy "images: admin insert" on storage.objects for insert to authenticated with check (bucket_id = 'site-images' and public.is_admin());
create policy "images: admin update" on storage.objects for update to authenticated using (bucket_id = 'site-images' and public.is_admin());
create policy "images: admin delete" on storage.objects for delete to authenticated using (bucket_id = 'site-images' and public.is_admin());

-- 4) Starter gallery photos (the 35 photos already inside the website folder) --
insert into public.gallery (url, caption, sort)
select * from (values
  ('images/gallery/g01.jpg', 'Pandangan hadapan premis operasi', 1),
  ('images/gallery/g02.jpg', 'Ruang berbumbung untuk lori dan kerja pembaikan', 2),
  ('images/gallery/g03.jpg', 'Kawasan bengkel dan parkir kenderaan', 3),
  ('images/gallery/g04.jpg', 'Ruang parkir lori serta struktur bumbung bengkel', 4),
  ('images/gallery/g05.jpg', 'Papan maklumat dan kabinet simpanan fail', 5),
  ('images/gallery/g06.jpg', 'Pandangan keseluruhan pejabat pentadbiran', 6),
  ('images/gallery/g07.jpg', 'Ruang pentadbiran dan kabinet rekod', 7),
  ('images/gallery/g08.jpg', 'Sudut kerja komputer dan penyelarasan tugas', 8),
  ('images/gallery/g09.jpg', 'Kemudahan meja kerja dan rekod operasi', 9),
  ('images/gallery/g10.jpg', 'Ruang komputer untuk penyelarasan operasi', 10),
  ('images/gallery/g11.jpg', 'Sudut kerja dan peralatan penyelenggaraan bengkel', 11),
  ('images/gallery/g12.jpg', 'Ruang pembaikan lori dan peralatan bengkel', 12),
  ('images/gallery/g13.jpg', 'Rak penyimpanan alat ganti dan komponen lori', 13),
  ('images/gallery/g14.jpg', 'Kaunter dokumen dan peralatan keselamatan', 14),
  ('images/gallery/g15.jpg', 'Kaunter kerja untuk dokumentasi bengkel', 15),
  ('images/gallery/g16.jpg', 'Proses pemuatan barangan di kawasan gudang', 16),
  ('images/gallery/g17.jpg', 'Lori kotak di kawasan parkir pelanggan', 17),
  ('images/gallery/g18.jpg', 'Pemuatan kepingan besi ke atas lori', 18),
  ('images/gallery/g19.jpg', 'Pengendalian bahan logam menggunakan forklift', 19),
  ('images/gallery/g20.jpg', 'Penghantaran menggunakan lori kotak ke premis pelanggan', 20),
  ('images/gallery/g21.jpg', 'Penghantaran bahan binaan dengan lori kargo terbuka', 21),
  ('images/gallery/g22.jpg', 'Lori kargo terbuka untuk penghantaran luar premis', 22),
  ('images/gallery/g23.jpg', 'Operasi lori kotak di kawasan bangunan industri', 23),
  ('images/gallery/g24.jpg', 'Lori kotak di ruang pemunggahan', 24),
  ('images/gallery/g25.jpg', 'Penyediaan dan susunan peralatan pengangkutan', 25),
  ('images/gallery/g26.jpg', 'Lori kotak di hadapan premis perindustrian', 26),
  ('images/gallery/g27.jpg', 'Pengangkutan peralatan mesin industri', 27),
  ('images/gallery/g28.jpg', 'Lori kotak di tapak perindustrian', 28),
  ('images/gallery/g29.jpg', 'Lori kotak 10 tan semasa proses pemuatan', 29),
  ('images/gallery/g30.jpg', 'Pemunggahan peralatan menggunakan tail-lift', 30),
  ('images/gallery/g31.jpg', 'Pengendalian peralatan industri sebelum pemuatan', 31),
  ('images/gallery/g32.jpg', 'Peralatan industri disediakan untuk penghantaran', 32),
  ('images/gallery/g33.jpg', 'Pengisian bahan api lori sebelum operasi', 33),
  ('images/gallery/g34.jpg', 'Penghantaran genset industri menggunakan lori kren', 34),
  ('images/gallery/g35.jpg', 'Penggunaan kaki penstabil lori kren semasa kerja', 35)
) as v(url, caption, sort)
where not exists (select 1 from public.gallery);

-- =====================================================================
-- 5) MAKE SOMEONE AN ADMIN  (run AFTER you created their user, see guide)
--    Replace the e-mail with the admin's real login e-mail, then run
--    just this one statement:
--
-- insert into public.admins (user_id)
-- select id from auth.users where email = 'admin@example.com'
-- on conflict do nothing;
-- =====================================================================
