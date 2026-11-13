-- EzanAI — bulut yedekleme şeması (Supabase / PostgreSQL)
--
-- Kullanım: Supabase > SQL Editor > New query içine yapıştırıp çalıştırın.
-- Kimlik doğrulama anonim oturumla yapılır; e-posta/ad/telefon İSTENMEZ.
-- Yedek paketi tek bir satırda (jsonb) tutulur ve yalnızca sahibi erişebilir.

create table if not exists public.user_data (
  user_id uuid primary key references auth.users (id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

comment on table public.user_data is
  'EzanAI kullanıcı verisi yedeği (anonim kimlik, RLS ile korunur)';

alter table public.user_data enable row level security;

-- Tablo sahibi (postgres) bile RLS'e tabi olsun: yanlışlıkla service_role
-- anahtarıyla yapılan sorguların veri sızdırmasını engeller.
alter table public.user_data force row level security;

-- Kötüye kullanım koruması: tek yedek 10 MB'ı aşamaz (Supabase kota ve
-- maliyet sınırı). Uygulama yedeği normalde 1 MB'ın altındadır.
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'user_data_payload_size'
  ) then
    alter table public.user_data
      add constraint user_data_payload_size
      check (pg_column_size(payload) <= 10 * 1024 * 1024);
  end if;
end $$;

drop policy if exists "kendi satiri okunur" on public.user_data;
create policy "kendi satiri okunur" on public.user_data
  for select using (auth.uid() = user_id);

drop policy if exists "kendi satiri yazilir" on public.user_data;
create policy "kendi satiri yazilir" on public.user_data
  for insert with check (auth.uid() = user_id);

drop policy if exists "kendi satiri guncellenir" on public.user_data;
create policy "kendi satiri guncellenir" on public.user_data
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "kendi satiri silinir" on public.user_data;
create policy "kendi satiri silinir" on public.user_data
  for delete using (auth.uid() = user_id);

-- Yedek yükleme sırasında satır otomatik güncellenir.
create or replace function public.touch_user_data()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists user_data_touch on public.user_data;
create trigger user_data_touch
  before update on public.user_data
  for each row execute function public.touch_user_data();
