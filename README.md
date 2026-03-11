# Installation

```
curl https://raw.githubusercontent.com/betterwithranch/dotfiles/main/scripts/init.sh | zsh
```


# Usage

Script installs a `config` alias and a bare repo

To add a file:

`config add <filename>`


# Secrets

Secrets are managed with [1Password CLI](https://developer.1password.com/docs/cli/) using template files. The `scripts/secrets.sh` script finds all `.tpl` files and uses `op inject` to populate the real config files with values from your 1Password vault.

## Adding a new secret

1. Create a template file alongside the real config file, with a `.tpl` extension:

   ```
   # ~/.aws/credentials.tpl
   [default]
   aws_access_key_id = {{ op://Personal/AWS/access_key_id }}
   aws_secret_access_key = {{ op://Personal/AWS/secret_access_key }}
   ```

2. The `op://` reference format is `op://Vault/Item/Field`. To find the right values:

   ```
   op vault list
   op item list --vault Personal
   op item get "AWS" --vault Personal
   ```

3. Track the template in your dotfiles (it contains no real secrets):

   ```
   config add ~/.aws/credentials.tpl
   ```

4. Run the secrets script to inject values:

   ```
   source ~/scripts/secrets.sh
   ```

   This also runs automatically during `init.sh`.

## Project files

Project-specific files (secrets, local config, editor settings) are stored in `~/.project-templates/` and copied into `~/dev/` using the `create_project_files` script.

The directory structure under `~/.project-templates/<project>/` mirrors the project layout:

```
~/.project-templates/sanctum/otter/
  .env.tpl                          # template: secrets injected via op
  .claude/settings.local.json       # raw file: copied as-is
  settings/local.py                 # raw file: copied as-is
```

- **`.tpl` files** are processed with `op inject` — use `{{ op://Vault/Item/Field }}` for secrets
- **All other files** are copied directly

### Adding project files

1. Create a template directory matching your project path:

   ```
   mkdir -p ~/.project-templates/sanctum/otter
   ```

2. Add files. For secrets, use a `.tpl` extension:

   ```ini
   # ~/.project-templates/sanctum/otter/.env.tpl
   DATABASE_URL={{ op://Development/Otter/database_url }}
   STRIPE_SECRET_KEY={{ op://Development/Otter/stripe_secret_key }}
   RAILS_ENV=development
   PORT=3000
   ```

   For non-secret files, just place them directly:

   ```
   cp ~/dev/sanctum/otter/.claude/settings.local.json \
      ~/.project-templates/sanctum/otter/.claude/settings.local.json
   ```

3. Track in your dotfiles:

   ```
   config add ~/.project-templates/sanctum/otter/
   ```

4. Populate the project:

   ```
   create_project_files sanctum/otter
   ```

## Conventions

- System secret templates (e.g. `~/.aws/credentials.tpl`) live next to the real config file and are injected by `scripts/secrets.sh`
- Project files live in `~/.project-templates/<project-path>/` and are populated by `create_project_files`
- Only `.tpl` files inside hidden directories under `$HOME` (max depth 3) are discovered automatically by `secrets.sh`
- Never track real files containing secrets in source control
