#!/bin/bash
set -e

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m'

# Beolvassuk a .env fájl változóit
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo -e "${BLUE}Loaded .env variables${NC}"
fi

echo -e "${BLUE}=== NodeJS konténer leállítása ===${NC}"
docker compose -f nodejs/compose.yml down
echo -e "${GREEN}NodeJS konténer leállítva${NC}"

echo -e "${BLUE}=== Webstack / App konténer leállítása ===${NC}"
docker compose -f webstack/compose.yml down
echo -e "${GREEN}Webstack konténerek leállítva${NC}"

echo -e "${BLUE}=== DB konténer leállítása ===${NC}"
docker compose -f db/compose.yml down
echo -e "${GREEN}DB konténer leállítva${NC}"