#!/bin/bash

set -euo pipefail

# =========================
# Színek
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

section() { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }
success() { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
error() { echo -e "${RED}$1${NC}"; }

run_artisan() {
  if ! docker exec focuscmsdemo-app php artisan "$@"; then
    error "Artisan hiba: php artisan $*"
    docker logs focuscmsdemo-app --tail=50
    exit 1
  fi
}

# =========================
# .env betöltése
# =========================
section ".env betöltése"

if [[ -f .env ]]; then
  set -a
  source .env
  set +a
  success ".env betöltve"
else
  error "Hiba: .env nem található!"
  exit 1
fi

# =========================
# Könyvtárak
# =========================
section "Könyvtárak előkészítése"

mkdir -p db/db_data
mkdir -p webstack/www

chown -R ${DEV_UID}:${DEV_GID} db/db_data || true
chown -R ${DEV_UID}:${DEV_GID} webstack/www || true

success "Könyvtárak OK"

# =========================
# Docker hálózat
# =========================
section "Docker hálózat"

docker network inspect demo-net >/dev/null 2>&1 || \
docker network create --driver bridge demo-net

success "Network OK"

# =========================
# DB indítása
# =========================
section "DB konténer indítása"

docker compose -f db/compose.yml up -d
success "DB konténer elindítva"

section "DB várakozás"

echo -n "MariaDB TCP portra várunk"

until timeout 1 bash -c "</dev/tcp/127.0.0.1/3306" >/dev/null 2>&1; do
  echo -n "."
  sleep 2
done

echo
success "MariaDB elérhető"

# =========================
# Focus CMS klónozás
# =========================
section "Focus CMS klónozás"

if [[ ! -d "webstack/www/focuscms" ]]; then
  git clone https://github.com/hi-personal/focus-cms.git webstack/www/focuscms
  chown -R ${DEV_UID}:${DEV_GID} webstack/www || true
  success "Repo klónozva"
else
  warn "Repo már létezik"
fi

cd webstack/www/focuscms
[[ -f .env ]] || cp .env.example .env
cd ../../..

# =========================
# Webstack
# =========================
section "Webstack build + start"

docker compose -f webstack/compose.yml build
docker compose -f webstack/compose.yml up -d
success "Webstack fut"

# =========================
# Composer
# =========================
section "Composer install"

if ! docker exec focuscmsdemo-app composer install --no-interaction --prefer-dist; then
  error "Composer install hiba!"
  docker logs focuscmsdemo-app --tail=50
  exit 1
fi

success "Composer kész"

# =========================
# Node
# =========================
section "Node build + start"

docker compose -f nodejs/compose.yml build
docker compose -f nodejs/compose.yml up -d
success "Node konténer fut"

section "Node csomagok"

docker exec focuscmsdemo-nj npm install
success "Node csomagok kész"

# =========================
# Laravel
# =========================
section "Laravel inicializálás"

run_artisan key:generate
run_artisan migrate --force
run_artisan optimize:clear

success "Laravel inicializálva"

# =========================
# CMS install
# =========================
section "CMS telepítés"

run_artisan cms:install --no-interaction
success "CMS telepítve"

# =========================
# themes.json
# =========================
section "themes.json"

if [[ ! -f webstack/www/focuscms/themes.json ]]; then
cat > webstack/www/focuscms/themes.json << 'EOF'
{
    "require": {
        "focus-cms/focus-default-theme": "@dev"
    }
}
EOF
fi

success "themes.json OK"

# =========================
# modules.json
# =========================
section "modules.json"

if [[ ! -f webstack/www/focuscms/modules.json ]]; then
cat > webstack/www/focuscms/modules.json << 'EOF'
{
    "require": {
        "focus-cms/focus-cms-front-module": "@dev",
        "focus-cms/focus-cms-core-shortcodes": "@dev"
    }
}
EOF
fi

success "modules.json OK"

# =========================
# Composer update
# =========================
section "Modulok és sablonok telepítése"

if ! docker exec focuscmsdemo-app composer update --no-interaction; then
  error "Composer update hiba!"
  docker logs focuscmsdemo-app --tail=50
  exit 1
fi

success "Composer frissítve"

# =========================
# Modul setup
# =========================
section "Modul setup"

run_artisan module:setup FocusCmsCoreShortcodes
run_artisan module:setup FocusCmsFrontModule
success "Modulok aktiválva"

# =========================
# Theme setup
# =========================
section "Sablon setup"

run_artisan theme:setup FocusDefaultTheme
run_artisan theme:set FocusDefaultTheme
success "Sablon aktiválva"

# =========================
# Demo user
# =========================
section "Demo felhasználó létrehozása"

docker exec focuscmsdemo-app php artisan tinker --execute="
use App\Models\User;
use Illuminate\Support\Facades\Hash;

User::updateOrCreate(
    ['email' => 'demo@focuscms.dev'],
    [
        'name' => 'Demo User',
        'login' => 'demo',
        'nicename' => 'demo',
        'display_name' => 'Demo User',
        'email_verified_at' => now(),
        'password' => Hash::make('Demo_2026'),
        'status' => 'active',
        'role' => 'admin',
    ]
);
"

success "Demo felhasználó létrehozva"

# =========================
# Mail teszt (MailHog)
# =========================
section "Mail teszt futtatása (tinker nélkül)"

if ! docker exec focuscmsdemo-app php -r "
require 'vendor/autoload.php';
\$app = require 'bootstrap/app.php';
\$kernel = \$app->make(Illuminate\Contracts\Console\Kernel::class);
\$kernel->bootstrap();

Illuminate\Support\Facades\Mail::raw(
    'MailHog teszt',
    function (\$message) {
        \$message->from('test@focuscms.local', 'Focus CMS')
                ->to('demo@focuscms.demo')
                ->subject('MailHog Test');
    }
);
"; then
  error "Mail teszt hiba!"
  docker logs focuscmsdemo-app --tail=50
  exit 1
fi

success "Mail teszt lefutott"

section "Belépési adatok"

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}           FOCUS CMS DEMO LOGIN            ${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e ""
echo -e "${BLUE}Felhasználó:${NC} ${YELLOW}demo${NC}"
echo -e "${BLUE}Email:${NC}      ${YELLOW}demo@focuscms.demo${NC}"
echo -e "${BLUE}Jelszó:${NC}     ${YELLOW}Demo_2026${NC}"
echo -e ""
echo -e "${GREEN}============================================${NC}"

# =========================
# Jogosultság
# =========================
section "Jogosultság szinkron"

chown -R ${DEV_UID}:${DEV_GID} db/db_data webstack/www || true

success "=== INSTALL KÉSZ ==="