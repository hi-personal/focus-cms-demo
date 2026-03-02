#!/bin/bash
set -e

# Színek
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
NC='\033[0m'

# .env betöltése
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  echo -e "${BLUE}Loaded .env variables${NC}"
fi

echo -e "${BLUE}=== DB konténer indítása ===${NC}"
docker compose -f db/compose.yml up -d --no-build
echo -e "${GREEN}DB konténer elindítva${NC}"

echo -e "${BLUE}=== Webstack / App konténerek indítása ===${NC}"
docker compose -f webstack/compose.yml up -d --no-build
echo -e "${GREEN}Webstack konténerek elindítva${NC}"

echo -e "${BLUE}=== NodeJS konténer indítása ===${NC}"
docker compose -f nodejs/compose.yml up -d --no-build
echo -e "${GREEN}NodeJS konténer elindítva${NC}"

echo
echo -e "${GREEN}=== Minden konténer fut ===${NC}"