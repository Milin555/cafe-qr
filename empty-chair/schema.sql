-- Empty Chair — win-back engine schema.
--
-- business_id on every row, from line one. The engine is deliberately
-- business-type agnostic: a salon's "overdue for a haircut", a gym's "membership
-- lapsing", a clinic's "recall due" and a coaching class's "fee overdue" are the
-- same query with a different interval. Never fork this per vertical.
--
--   psql "$SUPABASE_DB_URL" -f schema.sql

create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------- tenants
create table if not exists businesses (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  owner_phone   text not null unique,
  -- salon | barber | gym | clinic | coaching — drives only the default interval
  -- and the message template. No branching logic beyond that, on purpose.
  business_type text not null default 'salon',
  lang          text not null default 'gu' check (lang in ('gu','hi','en')),
  -- fallback cadence in days, used until a customer has 2+ visits of their own
  default_interval_days int not null default 30,
  created_at    timestamptz not null default now()
);

-- ---------------------------------------------------------------- customers
create table if not exists customers (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id) on delete cascade,
  name        text not null,
  phone       text not null,
  notes       text,
  -- set when the owner says "stop messaging this one"
  muted_at    timestamptz,
  created_at  timestamptz not null default now(),
  -- one person, one row per business. Never global: a customer of one salon is
  -- not a customer of another, and the lists are never pooled.
  unique (business_id, phone)
);
create index if not exists customers_business on customers(business_id);

-- ---------------------------------------------------------------- visits
create table if not exists visits (
  id          uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id) on delete cascade,
  customer_id uuid not null references customers(id) on delete cascade,
  visited_on  date not null,
  service     text,
  amount      numeric(10,2),
  created_at  timestamptz not null default now()
);
create index if not exists visits_customer on visits(customer_id, visited_on desc);
create index if not exists visits_business on visits(business_id, visited_on desc);

-- ---------------------------------------------------------------- nudges
-- Every message the owner sends, and whether it brought someone back.
-- This table is the entire commercial argument: without attribution the owner
-- is paying on faith, and renews on faith. With it, renewal is arithmetic.
create table if not exists nudges (
  id           uuid primary key default gen_random_uuid(),
  business_id  uuid not null references businesses(id) on delete cascade,
  customer_id  uuid not null references customers(id) on delete cascade,
  sent_at      timestamptz not null default now(),
  -- whatsapp_manual = wa.me click-to-send from the owner's own number (v1).
  -- whatsapp_api    = automated template send once the WABA clears (v2).
  channel      text not null default 'whatsapp_manual',
  -- set when a visit lands within the attribution window after this nudge
  returned_visit_id uuid references visits(id) on delete set null
);
create index if not exists nudges_customer on nudges(customer_id, sent_at desc);
create index if not exists nudges_business on nudges(business_id, sent_at desc);

-- ---------------------------------------------------------------- isolation
-- DPDP: the cafe/salon is the data fiduciary, we process on its behalf.
-- One business can never read another's customer list. Not once.
alter table businesses enable row level security;
alter table customers  enable row level security;
alter table visits     enable row level security;
alter table nudges     enable row level security;

-- Owner identity comes from Supabase phone auth; businesses.owner_phone is the join.
create or replace function current_business_id() returns uuid
language sql stable as $$
  select id from businesses
  where owner_phone = (auth.jwt() ->> 'phone')
  limit 1
$$;

drop policy if exists own_business on businesses;
create policy own_business on businesses
  for all using (id = current_business_id());

drop policy if exists own_customers on customers;
create policy own_customers on customers
  for all using (business_id = current_business_id());

drop policy if exists own_visits on visits;
create policy own_visits on visits
  for all using (business_id = current_business_id());

drop policy if exists own_nudges on nudges;
create policy own_nudges on nudges
  for all using (business_id = current_business_id());

-- ---------------------------------------------------------------- the query
-- Per-customer cadence, not a flat rule. A person who comes every 24 days and
-- was last seen 40 days ago is overdue; someone who comes every 90 is not.
-- This is the one thing a paper register cannot do.
create or replace view overdue_customers as
with gaps as (
  -- date - date yields integer days in Postgres; first visit has a null gap
  select
    v.customer_id, v.business_id, v.visited_on, v.amount,
    v.visited_on - lag(v.visited_on)
      over (partition by v.customer_id order by v.visited_on) as gap_days
  from visits v
),
spans as (
  select
    customer_id,
    business_id,
    count(*)         as visit_count,
    max(visited_on)  as last_visit,
    avg(amount)      as avg_amount,
    sum(amount)      as lifetime_value,
    -- median, not mean: one long absence shouldn't reset someone's cadence
    percentile_cont(0.5) within group (order by gap_days) as median_gap
  from gaps
  group by customer_id, business_id
)
select
  c.id                as customer_id,
  c.business_id,
  c.name,
  c.phone,
  s.visit_count,
  s.last_visit,
  s.avg_amount,
  s.lifetime_value,
  coalesce(s.median_gap, b.default_interval_days)          as expected_gap,
  (current_date - s.last_visit)                            as days_since,
  (current_date - s.last_visit)
    - coalesce(s.median_gap, b.default_interval_days)      as overdue_by,
  (select max(n.sent_at) from nudges n
    where n.customer_id = c.id)                            as last_nudged_at
from customers c
join businesses b on b.id = c.business_id
join spans s      on s.customer_id = c.id
where c.muted_at is null
  and (current_date - s.last_visit)
        > coalesce(s.median_gap, b.default_interval_days);
