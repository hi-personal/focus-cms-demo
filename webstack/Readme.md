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