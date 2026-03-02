#!/bin/bash
set -e

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${BLUE}=== Uninstall folyamat elindítása ===${NC}"

# 1. Minden konténer leállítása
if [ -f ./down.sh ]; then
  echo -e "${BLUE}Futtatom a down.sh scriptet...${NC}"
  bash ./down.sh
  echo -e "${GREEN}Konténerek leállítva${NC}"
else
  echo -e "${RED}down.sh nem található, kézzel kell leállítani a konténereket!${NC}"
fi

# 2. DB adat törlése
if [ -d ./db/db_data ]; then
  echo -e "${BLUE}DB adat törlése (db/db_data)...${NC}"
  rm -rf ./db/db_data
  echo -e "${GREEN}DB adatok törölve${NC}"
else
  echo -e "${RED}db/db_data mappa nem található${NC}"
fi

# 3. Web tartalom törlése
if [ -d ./webstack/www/focuscms ]; then
  echo -e "${BLUE}Web tartalom törlése (webstack/www/focuscms)...${NC}"
  rm -rf ./webstack/www/focuscms
  echo -e "${GREEN}Web tartalom törölve${NC}"
else
  echo -e "${RED}webstack/www/focuscms mappa nem található${NC}"
fi

echo -e "${GREEN}=== Uninstall kész! A projekt teljesen törölve ===${NC}"