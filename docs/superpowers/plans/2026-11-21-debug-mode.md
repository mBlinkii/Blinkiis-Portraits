# Debug-Modus Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `/bp debugmode` schaltet für den aktuellen Charakter alles außer BP, den aktiven unterstützten Addons, BugSack und !BugGrabber ab. `/bp debugmode off` stellt den alten Zustand wieder her.

**Architecture:** Die Auswahl-Logik und das Speichern liegen in `debugmode.lua`, offline testbar mit nachgebauter `C_AddOns`-API. `cmd.lua` bindet sie an Befehle, Popup und Reload. Ein Login-Hinweis kommt aus `PLAYER_ENTERING_WORLD`.

**Tech Stack:** WoW Lua 5.1, `C_AddOns`, AceDB (`db.char`), StaticPopup.

**Spec:** `docs/superpowers/specs/2026-11-21-debug-mode-design.md`

## Global Constraints

- Behalten werden: der eigene Ordner (`addonName`), `BugSack`, `!BugGrabber`, alle aktiven Provider-Addons (`provider.addons`), `JiberishIcons`, `ElvUI_JiberishIcons`, deren Abhängigkeiten rekursiv sowie Load-on-Demand-Addons, deren Abhängigkeiten alle behalten werden. Addons, die von `Blinkiis_Portraits` abhängen, werden nie wegen dieser letzten Regel behalten.
- Nur für den aktuellen Charakter (`UnitName("player")` als Ziel von `DisableAddOn`/`EnableAddOn`/`GetAddOnEnableState`).
- Gespeichert in `db.char.debugMode = { active = true, disabled = { names } }`.
- Neue Datei in alle 6 TOCs, neue Strings in `Locales/enUS.lua`.

## Review Focus

1. **Debug-Modus zweimal einschalten:** Die gespeicherte Liste darf nicht durch eine leere zweite Liste überschrieben werden. Test in Task 1.
2. **Ein Addon wurde während des Modus deinstalliert:** `off` überspringt es ohne Fehler. Test in Task 1.
3. **Abhängigkeitszyklus (A hängt von B ab, B von A):** Keine Endlosschleife. Test in Task 1.
4. **Addon ist abgeschaltet, aber Load-on-Demand:** Abgeschaltete Addons bleiben abgeschaltet und werden nicht in die Liste aufgenommen. Test in Task 1.
5. **`off` ohne aktiven Modus:** Kurze Meldung, kein Reload. Prüfung in Task 2 im Spiel.

---

### Task 1: Auswahl und Speichern (offline getestet)

**Files:**
- Create: `Blinkiis_Portraits/debugmode.lua` (in den TOCs nach `cmd.lua`)
- Modify: `tests/wow_stubs.lua` (`C_AddOns`: `GetNumAddOns`, `GetAddOnInfo(i) -> name`, `GetAddOnEnableState(name, char) -> 0|2`, `IsAddOnLoadOnDemand`, `GetAddOnDependencies(name) -> ...`, `DisableAddOn`, `EnableAddOn`; Helfer `setAddOnList({ {name=, enabled=, lod=, deps={}} })`, `UnitName`)
- Create: `tests/test_debugmode.lua`

**Interfaces:**
- Consumes: `BLINKIISPORTRAITS:GetProviders()` (Task 3 des Plugin-Plans)
- Produces:
  - `BLINKIISPORTRAITS:GetDebugModeKeepSet(ownFolder) -> { [name] = true }`
  - `BLINKIISPORTRAITS:EnableDebugMode(ownFolder) -> disabledCount` (speichert die Liste, schaltet ab, kein Reload)
  - `BLINKIISPORTRAITS:DisableDebugMode() -> restoredCount | nil` (nil, wenn nicht aktiv)
  - `BLINKIISPORTRAITS:IsDebugModeActive() -> boolean`

- [ ] **Step 1: Test schreiben** mit diesen Asserts: Behalten werden BP, BugSack, !BugGrabber, ElvUI (aktiv, Provider) und `ElvUI_Libraries` (Abhängigkeit) sowie `ElvUI_Options` (LOD, hängt nur von ElvUI ab). Abgeschaltet werden `ElvUI_MerathilisUI` (nicht LOD), `BP_ExamplePlugin` (hängt von BP ab, auch als LOD), `Details` und ein aktives SUF (Provider), das nicht installiert ist. Ein abgeschaltetes `Cell` bleibt aus und steht nicht in der Liste. Ein Zyklus A↔B bricht ab. Zweites `EnableDebugMode` ändert die Liste nicht. `DisableDebugMode` schaltet genau die Liste wieder ein und überspringt ein zwischendurch entferntes Addon. Danach ist `IsDebugModeActive()` falsch, und ein zweites `DisableDebugMode` gibt nil.
- [ ] **Step 2: ausführen, Fehlschlag sehen** `D:\Dev\tools\lua51\lua.exe tests/run.lua`
- [ ] **Step 3: `debugmode.lua` umsetzen**
- [ ] **Step 4: Suite grün**
- [ ] **Step 5: commit** `"Add a debug mode that keeps only BP and its supported addons"`

### Task 2: Befehle, Popup, Login-Hinweis

**Files:**
- Modify: `Blinkiis_Portraits/cmd.lua` (`debugmode` und `debugmode off`), `Blinkiis_Portraits/popup.lua` oder `cmd.lua` (StaticPopup `BLINKIISPORTRAITS_DEBUGMODE` mit Bestätigung, danach `ReloadUI()`), `Blinkiis_Portraits/core.lua` (`PLAYER_ENTERING_WORLD`: Hinweis, wenn aktiv), `Blinkiis_Portraits/Locales/enUS.lua`, `docs/plugin-api.md` nicht nötig, `CHANGELOG.md` (NEW-Eintrag unter 1.64)

- [ ] **Step 1: umsetzen.** Texte:
  - Popup: `L["Debug mode turns off every addon except Blinkiis Portraits, its supported unit frame addons, BugSack and BugGrabber for this character, then reloads the UI. Continue?"]`
  - Login: `L["Debug mode is active, other addons are turned off. Type /bp debugmode off to restore them."]`
  - `off` ohne Modus: `L["Debug mode is not active."]`
- [ ] **Step 2: Syntax, luacheck, Suite grün**
- [ ] **Step 3: Im Spiel prüfen (Blinkii):** `/bp debugmode` → Popup → Reload → Addon-Liste zeigt nur die behaltenen, Hinweis im Chat. `/bp debugmode off` → Reload → alter Zustand. `/bp debugmode off` erneut → Meldung, kein Reload.
- [ ] **Step 4: commit** `"Add /bp debugmode commands"`
