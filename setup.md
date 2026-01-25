# MyFlutterPersonalApp - Development Setup Guide

This guide covers local development setup for **macOS**, **Linux**, and **Windows**.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Supabase CLI Installation](#supabase-cli-installation)
3. [Project Setup](#project-setup)
4. [Running the App](#running-the-app)
5. [Supabase Commands Reference](#supabase-commands-reference)
6. [External Supabase Docker Setup](#external-supabase-docker-setup)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:
- **Flutter SDK** (3.6+) installed and in PATH
- **Docker Desktop** running (required for local Supabase)
- **Git** installed

Verify Flutter installation:
```bash
flutter doctor
```

---

## Supabase CLI Installation

### macOS
```bash
brew install supabase/tap/supabase
```

### Linux (Homebrew)
```bash
# Install Homebrew first if not present: https://brew.sh
brew install supabase/tap/supabase
```

### Linux (Alternative - Direct Download)
```bash
# Download latest release
curl -L https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.tar.gz | tar -xz

# Move to PATH
sudo mv supabase /usr/local/bin/
```

### Windows (Scoop)
```powershell
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### Windows (Chocolatey)
```powershell
choco install supabase
```

Verify installation:
```bash
supabase --version
```

---

## Project Setup

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd MyFlutterPersonalApp
flutter pub get
```

### 2. Link to Remote Supabase Project (if applicable)

```bash
supabase link --project-ref your-project-ref
```

### 3. Pull Existing Schema

```bash
supabase db pull
```

### 4. Start Local Supabase

```bash
supabase start
```

This starts the local Supabase stack. Access Studio at: **http://localhost:54323**

---

## Running the App

### Option A: Using Derry (Recommended)

Derry is a script runner for Dart. Install it globally:

#### macOS / Linux (zsh)
```bash
dart pub global activate derry
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

#### macOS / Linux (bash)
```bash
dart pub global activate derry
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc
```

#### Windows (PowerShell)
```powershell
dart pub global activate derry

# Add to PATH permanently (run as Administrator or add manually)
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"

# To make permanent, add to your PowerShell profile:
# notepad $PROFILE
# Add: $env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"
```

#### Windows (CMD)
```cmd
dart pub global activate derry

:: Add to PATH via System Properties > Environment Variables
:: Add: %USERPROFILE%\AppData\Local\Pub\Cache\bin
```

#### Available Derry Commands

```bash
# Development (VS Code debugging with hot reload)
derry start:android  # Launch on Android emulator
derry start:ios      # Launch on iOS simulator (macOS)
derry start:both     # Launch on both platforms (macOS)

# Production builds
derry build          # Build for iOS and Android
derry build:ios      # Build IPA for App Store
derry build:android  # Build AAB for Play Store
derry build:apk      # Build APKs for direct install

# Utilities
derry clean          # Clean and reinstall dependencies
derry test           # Run tests
derry analyze        # Run static analysis
```

### VS Code Launch with Derry

The `start:*` commands provide a fully automated launch experience:

**What happens:**
1. **Terminal prompts** for environment (`dev`/`prod`) and build mode (`debug`/`profile`/`release`)
2. **Auto-creates emulator/simulator** if none exists
3. **Auto-starts** the emulator/simulator if not running
4. **Generates VS Code config** with correct device IDs
5. **Triggers F5** in VS Code to start debugging with full hot reload

This works cross-platform: **macOS**, **Linux**, and **Windows**.

### Option B: Using Flutter Directly

```bash
# Development (local Supabase)
flutter run --dart-define=ENV=dev

# Production
flutter run --dart-define=ENV=prod
```

---

## Supabase Commands Reference

| Command | Description |
|---------|-------------|
| `supabase start` | Start local Supabase stack |
| `supabase stop` | Stop local Supabase stack |
| `supabase db pull` | Pull schema from remote to create migrations |
| `supabase db push` | Push migrations to remote |
| `supabase db reset` | Reset local DB (applies all migrations) |
| `supabase db diff -f <name>` | Generate migration from local changes |
| `supabase migration up` | Apply migrations without data loss |
| `supabase status` | Show local Supabase status and URLs |

### Local Supabase URLs (Default Ports)

| Service | URL |
|---------|-----|
| API | http://localhost:54321 |
| Studio | http://localhost:54323 |
| Inbucket (Email) | http://localhost:54324 |
| Database | postgresql://postgres:postgres@localhost:54322/postgres |

---

## Connecting to Remote Supabase Server

If you want to run Supabase on a separate machine (e.g., a local network server) and connect your Flutter app to it, follow these steps.

### Server Setup (On Remote Machine)

Install Supabase CLI on the server and set it up the same way as locally:

```bash
# Install Supabase CLI (see installation section above)
brew install supabase/tap/supabase

# Clone the project and init
git clone <repository-url>
cd MyFlutterPersonalApp
supabase link --project-ref your-project-ref
supabase db pull
supabase start
```

After `supabase start`, note the credentials shown (API URL, anon key, etc.). The server will be accessible at `http://<server-ip>:54321`.

### Client Setup (Each Developer)

Each developer needs to update their local `assets/config/dev.json` to point to the server:

```json
{
  "env": "development",
  "enable_logging": true,
  "supabase": {
    "url": "http://<SERVER_IP>:54321",
    "url_android": "http://<SERVER_IP>:54321",
    "anon_key": "<ANON_KEY_FROM_SERVER>"
  },
  "storage": {
    "url": "http://<SERVER_IP>:54321/storage/v1/s3",
    "url_android": "http://<SERVER_IP>:54321/storage/v1/s3",
    "access_key": "<ACCESS_KEY_FROM_SERVER>",
    "secret_key": "<SECRET_KEY_FROM_SERVER>",
    "region": "local"
  }
}
```

Replace `<SERVER_IP>` with the server's IP address (e.g., `192.168.1.100`).

### Pushing Schema Changes

When the Supabase instance runs on a different machine than where you develop:

1. **Schema changes via Studio**: Make changes at `http://<server-ip>:54323`, then generate migration on server:
   ```bash
   # On server
   supabase db diff -f my_change
   git add supabase/migrations/
   git commit -m "Add migration"
   git push
   ```

2. **Pull migrations to local**: Other developers pull the new migration files via git.

3. **Push to production**: Run `supabase db push` from any machine that has the project linked to the remote Supabase project.

**Note:** The machine pushing to production needs to have run `supabase link --project-ref <ref>` to be authenticated with the remote project

---

## Troubleshooting

### Docker Not Running
```
Error: Cannot connect to Docker daemon
```
**Solution:** Start Docker Desktop application.

### Port Already in Use
```
Error: port 54321 is already in use
```
**Solution:** Stop other Supabase instances or change ports in `supabase/config.toml`.

### Flutter Command Not Found (Windows)
Ensure Flutter is in your PATH:
```powershell
# Check if Flutter is accessible
where.exe flutter
```

### Derry Command Not Found
Ensure pub cache bin is in PATH (see [Running the App](#running-the-app) section).

### Android Emulator Can't Connect to Local Supabase
- Use `10.0.2.2` instead of `localhost` in config
- The app already handles this via `url_android` in config files

### iOS Emulator Connection Issues
- Ensure Supabase is running
- Check that `http://127.0.0.1:54321` is accessible from Terminal

---

## Quick Start Summary

```bash
# 1. Install dependencies
flutter pub get

# 2. Start Supabase
supabase start

# 3. Run the app (with VS Code debugging)
derry start:both
# or without VS Code
flutter run --dart-define=ENV=dev
```

