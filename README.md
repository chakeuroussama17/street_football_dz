# Street Football DZ ⚽🇩🇿

Team-based street football matchmaking for Algeria. Captains create teams and post
games; any team can bid to play; the host picks an opponent; after the match the host
records the score and the visitors rate the host team. Teams climb a national league.

Built with Flutter + Supabase. Arabic-first (RTL), French in settings.

---

## One-time setup

### 1. Supabase project
1. Create a **new** Supabase project (separate from any other app).
2. In **Settings → API**, copy the **Project URL** and **anon/public key**.
3. Copy `.env.example` → `.env` and paste them in:
   ```
   SUPABASE_URL=https://YOUR-PROJECT.supabase.co
   SUPABASE_ANON_KEY=YOUR-ANON-KEY
   ```
   `.env` is gitignored — never commit it.

### 2. Database
In the Supabase **SQL editor**, run, in order:
1. `database/schema.sql` — tables, RLS, helper functions, the `team_standings` league view.
2. `database/storage.sql` — the `team-logos` and `game-photos` public buckets + policies.
3. `database/notifications.sql` — in-app notifications.

### 3. Login (testing mode — no verification)
For now registration is a single form (name, DOB, wilaya, phone) with **no OTP /
no SMS**. The phone is the account identity; under the hood the app uses
Supabase email/password with confirmation off.
1. **Authentication → Sign In / Providers → Email**: make sure it's enabled and
   turn **OFF "Confirm email"** (so sign-up is instant, no email sent).
2. That's it — no Phone provider, no Twilio needed for testing.
3. **Before launch**, switch back to real phone OTP (see `AuthService`) and wire
   an SMS provider (Twilio / Vonage / MessageBird).

### 4. Admin
Set `adminPhone` in `lib/core/services/supabase_service.dart` to your own number
(E.164, e.g. `+213…`). That account becomes the app admin.

---

## Run
```bash
flutter pub get
flutter gen-l10n      # regenerate translations after editing lib/l10n/*.arb
flutter run
```

Regenerate the launcher icon after replacing `assets/images/logo.png`:
```bash
dart run flutter_launcher_icons
```

## Test
```bash
flutter analyze
flutter test
```

## Project layout
```
lib/
  app/            app shell, theme/locale notifiers, router
  core/
    constants/    Algeria wilayas, game formats
    providers/    Riverpod session/state providers
    services/     Supabase-backed services
    theme/        colours, theme, text styles
    widgets/      shared widget kit
  features/
    auth/ home/ games/ league/ team/ profile/ settings/ admin/ notifications/
  l10n/           ARB files (ar default, fr, en template)
database/         SQL migrations (run in Supabase)
```
