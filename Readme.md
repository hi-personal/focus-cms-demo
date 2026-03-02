# Focus CMS – Docker Demo Telepítő

## Composer alapú Focus CMS modul- és sablontelepítő

**Szerző:** Hatala István
**Weboldal:** https://focuscms.hatalaistvan.hu

---

## 📦 A projektről

Ez a repository a **Focus CMS Docker alapú demo telepítője**.

A script automatikusan:

- Elindítja a MariaDB adatbázist
- Felépíti a PHP webstack konténert
- Telepíti a Composer függőségeket
- Telepíti a Node csomagokat
- Inicializálja a Laravel alkalmazást
- Telepíti a CMS modulokat és sablonokat
- Aktiválja az alapértelmezett sablont
- Létrehoz egy demo admin felhasználót
- Lefuttat egy MailHog teszt e-mail küldést

⚠️ A Focus CMS core nem része ennek a repository-nak, a telepítés során kerül klónozásra.

---

## 🐳 Követelmények

- Docker
- Docker Compose
- Git
- Linux alapú rendszer (ajánlott)

---

## 🚀 Telepítés

Repository klónozása:

```bash
git clone git@github.com:hi-personal/focus-cms-demo.git
cd focus-cms-demo
```

---

🧪 Fejlesztői megjegyzés (Firefox + Uppy preview)

Fejlesztői környezetben (localhost), Firefox alatt az Uppy képelőnézet generálásánál az alábbi hiba jelentkezhet a konzolban:

Blocked http://localhost from extracting canvas data because no user input was detected

Ez nem kép- vagy WebP-hiba, hanem a Firefox fingerprinting elleni védelméből ered, amely blokkolja a canvas pixeladatok kiolvasását.

Ideiglenes dev megoldás (Firefox)

Firefoxban:

Nyisd meg a címsorba írva:

about:config

Keresd meg a következő beállítást:

privacy.resistFingerprinting

Állítsd az értékét false-ra.

Ez lehetővé teszi a canvas pixeladatok kiolvasását az Uppy preview generálásához.

⚠️ Fontos:
Ez kizárólag fejlesztői környezetben javasolt.
Éles környezetben – ha minden asset és API azonos originről fut – a probléma nem jelentkezik.

Chromium alapú böngészők (Chrome, Vivaldi, Edge)

Chromium alapú böngészők esetén általában nincs szükség külön beállítás módosítására, mivel ezek nem alkalmazzák a Firefoxhoz hasonló fingerprinting-védelmet localhost környezetben.