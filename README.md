# Hamlet School Monitor

Flutter school management app with Supabase (auth, admin dashboard, teacher dashboard).

## Run locally

```bash
flutter pub get
flutter run -d web-server \
  --dart-define=SUPABASE_URL=your_supabase_url \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

Open the URL printed in the terminal (e.g. `http://localhost:xxxxx`).

## Supabase

Apply migrations in `supabase/migrations/` to your Supabase project.

## Stack

- Flutter / Dart
- Supabase (Auth, Postgres, Storage, Realtime)
- Riverpod, go_router, freezed
