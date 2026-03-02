#!/bin/bash

set -e

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Beolvassuk a .env fájl változóit
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo -e "${BLUE}Loaded .env variables${NC}"
else
  echo -e "${RED}Hiba: .env fájl nem található a projekt gyökerében!${NC}"
  exit 1
fi

echo -e "${BLUE}=== Docker hálózat ellenőrzés ===${NC}"
docker network inspect demo-net >/dev/null 2>&1 || \
docker network create --driver bridge demo-net
echo -e "${GREEN}Docker hálózat ellenőrizve / létrehozva${NC}"

echo -e "${BLUE}=== DB konténer indítása ===${NC}"
docker compose -f db/compose.yml up -d
echo -e "${GREEN}DB konténer fut${NC}"

echo -e "${BLUE}=== Webstack / App konténer ===${NC}"

if [ ! -d "webstack/www/focuscms" ]; then
  echo -e "${YELLOW}Repo klónozás...${NC}"
  git clone https://github.com/hi-personal/focus-cms.git webstack/www/focuscms
else
  echo -e "${GREEN}Repo már létezik, nem klónozunk${NC}"
fi

cd webstack/www/focuscms
[ -f .env ] || cp .env.example .env
cd ../../..

echo -e "${BLUE}Building Webstack...${NC}"
docker compose -f webstack/compose.yml build
echo -e "${GREEN}Webstack build kész${NC}"

echo -e "${BLUE}Starting Webstack...${NC}"
docker compose -f webstack/compose.yml up -d
echo -e "${GREEN}Webstack konténer fut${NC}"

echo -e "${BLUE}=== NodeJS konténer ===${NC}"
docker compose -f nodejs/compose.yml build
echo -e "${GREEN}NodeJS build kész${NC}"
docker compose -f nodejs/compose.yml up -d
echo -e "${GREEN}NodeJS konténer fut${NC}"

echo -e "${BLUE}=== NodeJS jogosultságok ===${NC}"
docker exec -u root focuscmsdemo-nj \
  chown -R ${DEV_UID}:${DEV_GID} /var/www/focuscms/node_modules || true
echo -e "${GREEN}NodeJS jogosultságok beállítva${NC}"

echo -e "${BLUE}=== Node csomagok telepítése ===${NC}"
docker exec focuscmsdemo-nj npm install
echo -e "${GREEN}Node csomagok telepítve${NC}"

echo -e "${BLUE}=== Laravel inicializálás ===${NC}"
docker exec focuscmsdemo-app composer update
docker exec focuscmsdemo-app php artisan key:generate
docker exec focuscmsdemo-app php artisan migrate --force
docker exec focuscmsdemo-app php artisan optimize:clear
echo -e "${GREEN}Laravel inicializálás kész${NC}"

echo -e "${BLUE}=== Mail teszt futtatása (tinker nélkül) ===${NC}"
docker exec focuscmsdemo-app php -r "
require 'vendor/autoload.php';
\$app = require 'bootstrap/app.php';
\$kernel = \$app->make(Illuminate\Contracts\Console\Kernel::class);
\$kernel->bootstrap();
Illuminate\Support\Facades\Mail::raw(
  'MailHog teszt',
  function (\$message) {
    \$message->from('test@focuscms.local', 'Focus CMS')
            ->to('demo@test.com')
            ->subject('MailHog Test');
  }
);
"
echo -e "${GREEN}Mail teszt lefutott${NC}"

echo -e "${BLUE}=== CMS Install Command futtatása ===${NC}"
docker exec focuscmsdemo-app php artisan cms:install --no-interaction
echo -e "${GREEN}CMS telepítve${NC}"

echo -e "${BLUE}=== themes.json létrehozása ===${NC}"
if [ ! -f webstack/www/focuscms/themes.json ]; then
cat > webstack/www/focuscms/themes.json << 'EOF'
{
    "require": {
        "focus-cms/focus-default-theme": "@dev"
    }
}
EOF
fi
echo -e "${GREEN}themes.json létrehozva${NC}"

echo -e "${BLUE}=== modules.json létrehozása ===${NC}"
if [ ! -f webstack/www/focuscms/modules.json ]; then
cat > webstack/www/focuscms/modules.json << 'EOF'
{
    "require": {
        "focus-cms/focus-cms-front-module": "@dev",
        "focus-cms/focus-cms-core-shortcodes": "@dev"
    }
}
EOF
fi
echo -e "${GREEN}modules.json létrehozva${NC}"

echo -e "${BLUE}=== Sablon és Modulok telepítése ===${NC}"
docker exec focuscmsdemo-app composer update
echo -e "${GREEN}Sablonok és modulok telepítve${NC}"

echo -e "${BLUE}=== Sablon inicializálása ===${NC}"
docker exec focuscmsdemo-app php artisan theme:setup FocusDefaultTheme
echo -e "${GREEN}Sablon inicializálva${NC}"

echo -e "${BLUE}=== Sablon beállítása aktuálisnak ===${NC}"
docker exec focuscmsdemo-app php artisan theme:set FocusDefaultTheme
echo -e "${GREEN}Sablon beállítva aktuálisnak${NC}"

echo -e "${GREEN}=== Kész ===${NC}"