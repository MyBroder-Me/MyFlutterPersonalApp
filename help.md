# Local instalation
## 1. Install Supabase CLI (macOS)
```brew install supabase/tap/supabase```

## Or via npm (not sure if works)
```npm install -g supabase```

## 2. Initialize in your Flutter project
```supabase init```

## 3. Link to your existing remote project
```supabase link --project-ref your-db-name```

## 4. Pull existing schema from production
```supabase db pull```

# Useful commands

## Start local stack
```supabase start```

## Pull schema from production → creates migration files
```supabase db pull```

## Make changes locally (via Studio at localhost:54323 or SQL)
## Then generate a migration from your changes
```supabase db diff -f my_new_feature```

## Reset local DB to clean state (applies all migrations)
```supabase db reset```

## Push migrations to production when ready
```supabase db push```

## Stop local stack
```supabase stop```

## How to start a project

After installing all dart dependencies \
```dart pub get```

you will need to check scripts inside pubspec.yaml file. That file contains all usefull scripts to use. To be able to use that scripts you need to activate derry globally or execute \

```dart pub global run derry dev```

To been able to execute it as it is follow next steps (adapt it to your enviorment)

## 1. Activate derry globally
```dart pub global activate derry```

## 2. Add pub cache to your PATH (for zsh)
```echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc```

## 3. Reload your shell
```source ~/.zshrc```

## 4. Now try to start
```derry dev```

# Best solution
You can execute \
```derry setup``` \
This command will generate you a .vscode config to been able to launch on your device \
PD: THIS IS A FAST SETUP \
For more specific device settings and options you can config this manually.


