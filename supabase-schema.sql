create extension if not exists pgcrypto;

create table if not exists public.products (
  id text primary key,
  brand text not null,
  name text not null,
  category text not null check (category in ('Bags','Watches','Shoes','Accessories')),
  price numeric(12,2) not null default 0,
  status text not null default 'available' check (status in ('available','reserved','sold')),
  badge text,
  image_url text not null,
  description text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.valuation_requests (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  category text not null,
  details text,
  status text not null default 'new' check (status in ('new','contacted','completed','declined')),
  created_at timestamptz not null default now()
);

create table if not exists public.contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text,
  email text,
  message text not null,
  status text not null default 'new',
  created_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.products enable row level security;
alter table public.valuation_requests enable row level security;
alter table public.contact_messages enable row level security;
alter table public.site_settings enable row level security;

drop policy if exists "Public catalog read" on public.products;
create policy "Public catalog read" on public.products for select to anon, authenticated using (true);
drop policy if exists "Public settings read" on public.site_settings;
create policy "Public settings read" on public.site_settings for select to anon, authenticated using (true);
drop policy if exists "Public valuation submit" on public.valuation_requests;
create policy "Public valuation submit" on public.valuation_requests for insert to anon, authenticated with check (char_length(name) between 1 and 120 and char_length(phone) between 7 and 30);
drop policy if exists "Public contact submit" on public.contact_messages;
create policy "Public contact submit" on public.contact_messages for insert to anon, authenticated with check (char_length(name) between 1 and 120 and char_length(message) between 1 and 3000);

insert into public.products (id,brand,name,category,price,status,badge,image_url,sort_order) values
('p1','VVIP Edit','Signature Top Handle Bag','Bags',12800,'available','NEW ARRIVAL','assets/product-1.jpg',1),
('p2','Swiss Timepieces','Two-Tone Professional Watch','Watches',42900,'available','COLLECTOR''S PIECE','assets/product-2.jpg',2),
('p3','Italian House','Monogram Drawstring Boots','Shoes',3900,'available','JUST IN','assets/product-3.jpg',3),
('p4','Swiss Timepieces','Diamond Dial Classic Watch','Watches',28500,'available','CERTIFIED','assets/product-4.jpg',4),
('p5','Paris Edit','Vintage Drawstring Shoulder Bag','Bags',6900,'available','VINTAGE','assets/product-5.jpg',5),
('p6','VVIP Edit','Emerald Evening Bag','Bags',5200,'sold','SOLD','assets/hero.png',6),
('p7','Fine Jewellery','Gold Statement Bracelet','Accessories',2600,'available','LIMITED','assets/product-2.jpg',7),
('p8','Italian House','Structured City Tote','Bags',8600,'available','CURATED','assets/product-1.jpg',8)
on conflict (id) do update set brand=excluded.brand,name=excluded.name,category=excluded.category,price=excluded.price,status=excluded.status,badge=excluded.badge,image_url=excluded.image_url,sort_order=excluded.sort_order,updated_at=now();

insert into public.site_settings (key,value) values
('contact','{"company":"VVIP PARIS MILAN GLOBAL","phone":"014-3444311","address":"A-20-3A, VERVE SUITES, 58000, K.L.","email":"vvipparismilanglobal.com","instagram":"vvip_paris_milan_global"}'::jsonb)
on conflict (key) do update set value=excluded.value,updated_at=now();
