-- CHISTIYA HIDAYAT MISSION - Accounts Ledger Migration v1.0
-- Additive migration only. Does not drop, truncate, reset, or modify existing records.

create table if not exists public.account_entries (
  id uuid primary key default gen_random_uuid(),
  entry_type text not null check (entry_type in ('income','expense')),
  source_type text not null,
  source_id uuid not null,
  entry_date date not null default current_date,
  category text not null,
  amount numeric(12,2) not null check (amount > 0),
  payment_method text,
  reference_number text,
  description text,
  created_at timestamptz not null default now(),
  unique (source_type, source_id)
);

create index if not exists account_entries_entry_date_idx
  on public.account_entries (entry_date desc);
create index if not exists account_entries_entry_type_idx
  on public.account_entries (entry_type);

alter table public.account_entries enable row level security;

-- Create the same admin-only access rule used by the existing application tables.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public'
      and tablename = 'account_entries'
      and policyname = 'admin_all'
  ) then
    create policy admin_all on public.account_entries
      for all to authenticated
      using (public.is_active_admin())
      with check (public.is_active_admin());
  end if;
end
$$;

comment on table public.account_entries is
  'Cashbook ledger entries posted by fee payments and expense vouchers; historical source records are not backfilled automatically.';
