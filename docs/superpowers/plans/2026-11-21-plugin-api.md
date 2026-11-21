# Plugin-API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** BP bekommt eine öffentliche, versionierte Plugin-API (`BLINKIISPORTRAITS.API`). Plugins können damit Frame-Provider, Styles und Icon-Sets registrieren, eigene Elemente anhängen und in BPs Elemente eingreifen, ohne dass BP selbst zum Unitframe-Addon wird.

**Architecture:** Ein neues Modul `api.lua` enthält die Registries, die Callbacks (CallbackHandler-1.0) und die Plugin-Verwaltung (AceDB-Namespaces, Tab „Plugins“). Die eingebauten Unitframe-Integrationen ziehen auf die Provider-Registry um (`portraits/providers.lua`). Die Portrait-Engine in `portraits/functions.lua` wird Element für Element auf ein Element-Modell umgebaut (`portraits/elements.lua`): Pre → Override oder Update → Post. BPs Verhalten ohne Plugins bleibt nach jeder Aufgabe identisch.

**Tech Stack:** WoW Lua 5.1, Ace3 (AceAddon, AceDB, AceConfig, CallbackHandler-1.0), alle Flavors (Mainline, Camelot, Mists, TBC, Vanilla, Wrath). Offline-Tests mit `D:\Dev\tools\lua51\lua.exe` (Lua 5.1, siehe `D:\Dev\tools\AGENTS.md`).

**Spec:** `docs/superpowers/specs/2026-11-21-plugin-api-design.md`

## Global Constraints

- Nur ein Global: `BLINKIISPORTRAITS`. Öffentlich ist nur `BLINKIISPORTRAITS.API`.
- `API.version = 1`, friert erst mit dem Release ein. Bis dahin bleibt alles auf dem Branch `feature/plugin-api`.
- Keine neuen Libraries. Kein Code 1:1 aus oUF, ElvUI oder Sashs VuppEdit, nur das Muster.
- stylua (`D:\Dev\tools\stylua\stylua.exe`, aus dem Repo-Root, nur geänderte Dateien), luacheck (`D:\Dev\tools\luacheck\luacheck.exe`, nur neue Warnungen zählen).
- Kaum Kommentare, einzeilig, englisch. Upvalues für API im Hot Path. Keine Allokation pro Event.
- Neue Addon-Dateien in alle 6 TOCs. Neue sichtbare Strings über `L[...]` in `Locales/enUS.lua`.
- Secret Values werden unverändert an Plugins weitergegeben. Geheime Werte werden nie verglichen und nie als Tabellenschlüssel benutzt.
- Frames erstellen, ankern und sichere Attribute setzen nur außerhalb des Kampfes (der bestehende Retry in `LoadPortraits`).
- Plugin-Einstellungen im Export und Import nur für aktivierte, geladene und per `NewPlugin` registrierte Plugins. Übersprungene Plugins werden gemeldet. Alte Strings importieren wie heute.
- Pro Element genau ein `Override`. Ein zweites wird abgelehnt, mit einer Warnung, die beide Plugins nennt.
- Plugin-Funktionen laufen über `securecallfunction`. Fallback ist `xpcall(fn, geterrorhandler(), ...)`, wenn es die Funktion nicht gibt.
- **Testbarkeit:** `api.lua`, `portraits/providers.lua` und `portraits/elements.lua` rufen beim Laden keine WoW-API außer denen, die `tests/wow_stubs.lua` nachbaut. Logik, die Frames braucht, steckt in Funktionen, die erst zur Laufzeit aufgerufen werden.

## Tests

Zwei Ebenen, jede Aufgabe nutzt beide.

**Offline (Lua 5.1, ohne Spiel):** für alle reine Logik: Registrierung, Versionsprüfung, Reihenfolge, Rückfälle, Datenumformung, Ablauf der Elemente.
- Ort: `tests/` im Repo-Root, außerhalb von `Blinkiis_Portraits/`, also nicht im Release-Zip.
- `tests/run.lua`: lädt `tests/wow_stubs.lua`, dann jede Datei `tests/test_*.lua` in einer eigenen Umgebung (`setfenv`). Gibt pro Test `ok`/`FAIL` aus, am Ende `N passed, M failed`, Exit-Code 1 bei Fehlern. Kleine eigene Asserts: `eq(actual, expected, label)`, `truthy(v, label)`, `errors(fn, label)`.
- `tests/wow_stubs.lua`: das Nötigste, damit LibStub, CallbackHandler-1.0, AceDB-3.0 und die getesteten BP-Dateien laden: `CreateFrame` (Tabelle mit No-op-Methoden), `securecallfunction` (ruft per `xpcall` auf und meldet Fehler an `geterrorhandler()`), `geterrorhandler` (sammelt Fehler in `reportedErrors`), `GetRealmName`, `UnitClass`, `UnitRace`, `UnitFactionGroup`, `GetCurrentRegion`, `GetLocale`, `format`, `strmatch`, `strfind`, `gmatch`, `wipe`, `tinsert`, `C_Timer.After` (sammelt Callbacks, die ein Test über `flushTimers()` ausführt), `InCombatLockdown` (über `setCombat(bool)` steuerbar), `IsAddOnLoaded` (über `setLoadedAddons{...}` steuerbar). Erweitert wird nur, was ein Test braucht.
- `tests/bp_env.lua`: `newBP()` baut ein frisches minimales `BLINKIISPORTRAITS` (mit `db` aus echtem AceDB auf leeren SavedVariables, `Print` sammelt Ausgaben in `printed`), lädt per `loadfile` die zu testenden Addon-Dateien mit `("Blinkiis_Portraits", {})` als Varargs. Die Ace3-Libs kommen aus `Blinkiis_Portraits/libs/`. Fehlen sie, bricht `run.lua` mit dem Hinweis ab, sie wie in der README beschrieben zu holen.
- Ausführen: `D:\Dev\tools\lua51\lua.exe tests/run.lua` aus dem Repo-Root.

**Im Spiel:** für alles, was gezeichnet wird, für Events, Secret Values und Combat Lockdown. Das Beispiel-Plugin `examples/BP_ExamplePlugin/` hat einen Selbsttest: `Check(label, condition)`, Slash `/bpex test` gibt `BP_ExamplePlugin: X/Y checks passed` aus und listet fehlgeschlagene Checks. Blinkii führt diese Schritte aus, der Umsetzer nennt nach jeder Aufgabe genau, was zu prüfen ist.

## Review Focus

1. **Registrierung im Kampf** (Plugin lädt per LoadOnDemand oder ruft `RegisterStyle` im Kampf): Erwartet wird, dass nichts taintet und der Refresh nach dem Kampf nachgeholt wird. Test in Task 4.
2. **Gespeicherter Provider, dessen Plugin nicht mehr installiert ist** (`profile.player.unitframe = "myuf"`): Erwartet wird, dass das Portrait wie bei `"auto"` an den nächsten verfügbaren Provider geht, ohne Fehler, und dass die Auswahl im Dropdown leer statt kaputt angezeigt wird. Test in Task 3.
3. **Plugin-Hook wirft bei jedem Event einen Fehler:** Erwartet wird, dass BPs Portrait weiter korrekt gezeichnet wird und der Fehler in BugSack landet. Test in Task 6.
4. **Geheime Werte in Hook-Argumenten** (Retail, Gegner im Instanzkampf): Erwartet wird, dass `PostUpdate` von Color und Ring geheime Werte bekommt, ohne dass BP sie vorher vergleicht. Test in Task 7.
5. **Gewählter Plugin-Style oder Plugin-Icon-Set fehlt nach dem Deaktivieren des Plugins:** Erwartet wird der Rückfall auf die Voreinstellung, wie heute bei gelöschten Custom-Packs. Test in Task 4.

---

### Task 1: Test-Harness, API-Gerüst und Plugin-Registrierung

**Files:**
- Create: `tests/run.lua`, `tests/wow_stubs.lua`, `tests/bp_env.lua`, `tests/test_plugins.lua`
- Create: `Blinkiis_Portraits/api.lua`
- Modify: alle 6 TOCs (`api.lua` direkt nach `options.lua`)
- Modify: `Blinkiis_Portraits/options.lua` (Tab `plugins_group`)
- Modify: `Blinkiis_Portraits/eui.lua` (neue Funktion `BLINKIISPORTRAITS:RefreshEllesmereUIOptions()`)
- Create: `examples/BP_ExamplePlugin/BP_ExamplePlugin.toc` (`## Dependencies: Blinkiis_Portraits`, Interface-Zeilen wie BP), `examples/BP_ExamplePlugin/core.lua`, `examples/BP_ExamplePlugin/checks.lua`

**Interfaces:**
- Produces:
  - `BLINKIISPORTRAITS.API` (Tabelle), `API.version = 1`
  - `API:NewPlugin(name: string, opts: {apiVersion: number, defaults?: table, options?: function -> AceConfigGroup}) -> plugin | nil, errorString`
  - `plugin.name`, `plugin.db` (AceDB-Namespace über `BLINKIISPORTRAITS.db:RegisterNamespace(name, opts.defaults)`)
  - `API:GetPlugin(name) -> plugin | nil`, `API:IteratePlugins() -> iterator(name, plugin)`
  - intern `BLINKIISPORTRAITS:SafeCall(fn, ...)` (securecallfunction oder xpcall-Fallback)
  - Test-Helfer aus dem Abschnitt „Tests“: `eq`, `truthy`, `errors`, `newBP`, `flushTimers`, `setCombat`, `setLoadedAddons`

- [ ] **Step 1: Branch `feature/plugin-api` von `main` anlegen**

- [ ] **Step 2: Harness bauen und mit einem Platzhaltertest prüfen**

Run: `D:\Dev\tools\lua51\lua.exe tests/run.lua`
Expected: `1 passed, 0 failed` (Platzhalter `eq(1, 1, "harness")`, danach wieder entfernen)

- [ ] **Step 3: `tests/test_plugins.lua` schreiben**

```lua
local BP = newBP({ "api.lua" })
local API = BP.API
eq(API.version, 1, "api version")
local plugin, err = API:NewPlugin("P1", { apiVersion = 1, defaults = { profile = { enabled = true } } })
truthy(plugin and not err, "NewPlugin returns plugin")
eq(plugin.db.profile.enabled, true, "namespace defaults")
eq(select(1, API:NewPlugin("P1", { apiVersion = 1 })), nil, "duplicate rejected")
eq(select(1, API:NewPlugin("P2", { apiVersion = 99 })), nil, "wrong apiVersion rejected")
truthy(#BP.printed == 2, "both rejections warned")
eq(API:GetPlugin("P1"), plugin, "GetPlugin")
BP.db:SetProfile("other")
eq(plugin.db.profile.enabled, true, "namespace follows profile")
BP:SafeCall(function() error("boom") end)
eq(#reportedErrors, 1, "SafeCall reports the error instead of raising")
```

- [ ] **Step 4: Ausführen, Fehlschlag prüfen**

Run: `D:\Dev\tools\lua51\lua.exe tests/run.lua` · Expected: FAIL, `api.lua` fehlt

- [ ] **Step 5: `api.lua` umsetzen**

Abgelehnt werden doppelte Namen und `apiVersion ~= API.version`: Rückgabe `nil` plus Fehlertext, Warnung über `BLINKIISPORTRAITS:Print`. `options` landet als `BLINKIISPORTRAITS.options.args.plugins_group.args[name]`. Der Tab ist nur sichtbar, wenn mindestens ein Plugin registriert ist (`hidden`). Danach `NotifyChange("BLINKIISPORTRAITS")` (nur wenn AceConfigRegistry geladen ist) und `RefreshEllesmereUIOptions()`, falls vorhanden.

- [ ] **Step 6: Offline-Tests grün** · Run wie Step 4 · Expected: alle passed

- [ ] **Step 7: `RefreshEllesmereUIOptions` in `eui.lua`**

Baut `BuildPluginSpec()` neu und registriert es erneut bei EllesmereUI. Gibt es dort keine Funktion zum Neu-Registrieren, wird die Spec-Tabelle des registrierten Plugins in place ersetzt. Welcher Weg geht, prüft der Umsetzer in den EllesmereUI-Quellen. Ohne EUI passiert nichts.

- [ ] **Step 8: Beispiel-Plugin mit Harness und den Checks `API exists`, `API version 1`, `NewPlugin returns plugin`. Im Spiel prüfen** (Blinkii): Beispiel per Junction nach `Interface\AddOns\BP_ExamplePlugin`, `/reload`, `/bpex test` → `3/3`. `/bp` zeigt den Tab „Plugins“, auch in den ElvUI- und EllesmereUI-Optionen.

- [ ] **Step 9: stylua, luacheck, commit** `"Add the plugin API skeleton with plugin registration"`

---

### Task 2: Callbacks und Helfer

**Files:**
- Modify: `Blinkiis_Portraits/api.lua`, `Blinkiis_Portraits/core.lua` (`LoadPortraits`, `OnInitialize`), `Blinkiis_Portraits/portraits/functions.lua` (`CreatePortrait`, `SetupUnitPortrait`, `Update`, `RemovePortrait`)
- Create: `tests/test_callbacks.lua`
- Modify: `examples/BP_ExamplePlugin/checks.lua`

**Interfaces:**
- Consumes: `API` aus Task 1
- Produces:
  - `API.RegisterCallback(target, event, method)`, `API.UnregisterCallback(target, event)`, intern `BLINKIISPORTRAITS:Fire(event, ...)`
  - Events und Argumente, exakt so: `PortraitCreated(portrait)`, `PortraitSetup(portrait)`, `PortraitUnitChanged(portrait, unit)`, `PortraitUpdated(portrait, event)`, `PortraitRemoved(portrait)`, `PortraitsLoaded()`, `ProfileChanged()`
  - Helfer: `API:IsSecretValue(v) -> boolean`, `API:SafeValue(v) -> v | nil`, `API:GetUnitColor(unit, isDead, isPlayer, class, isSecret) -> color` (durchgereicht an die bestehenden Funktionen), `API:GetPortraits() -> iterator(key, portrait)` über `BLINKIISPORTRAITS.Portraits`
  - Stabile Portrait-Felder: `unit, type, key, db, isPlayer, isDead, isSecret, unitClass, parentFrame, parentAddon, texture, portrait, mask, bg, extra, ring`, dazu `portrait.plugins = {}` (angelegt in `CreatePortrait`). `portrait.key` wird neu in `SetupUnitPortrait` gesetzt (`opts.key`).

- [ ] **Step 1: `tests/test_callbacks.lua` schreiben**

```lua
local BP = newBP({ "api.lua" })
local got = {}
BP.API.RegisterCallback(got, "PortraitSetup", function(_, p) got.setup = p end)
BP:Fire("PortraitSetup", "P")
eq(got.setup, "P", "callback receives portrait")
BP.API.UnregisterCallback(got, "PortraitSetup")
BP:Fire("PortraitSetup", "Q")
eq(got.setup, "P", "unregistered callback silent")
BP.API.RegisterCallback(got, "PortraitsLoaded", function() error("boom") end)
BP.API.RegisterCallback(got, "PortraitRemoved", function() got.after = true end)
BP:Fire("PortraitsLoaded"); BP:Fire("PortraitRemoved")
truthy(got.after, "error in one handler does not stop others")
BP.Portraits = { player = {}, target = {} }
local n = 0; for _ in BP.API:GetPortraits() do n = n + 1 end
eq(n, 2, "GetPortraits iterates")
eq(BP.API:SafeValue(5), 5, "SafeValue passes plain values")
```

- [ ] **Step 2: Ausführen, Fehlschlag prüfen** · Run: `D:\Dev\tools\lua51\lua.exe tests/run.lua`

- [ ] **Step 3: Umsetzen**

`LibStub("CallbackHandler-1.0"):New(API)`. `Fire` kostet nichts, solange kein Abonnent für das Event existiert (Zähler über `OnUsed`/`OnUnused`). `PortraitUpdated` nur im Zweig `hasStateChanged`. `PortraitUnitChanged`, wenn `portrait.unit` nach dem Auflösen vom vorherigen Wert abweicht. `ProfileChanged` an `OnProfileChanged`, `OnProfileCopied`, `OnProfileReset`.

- [ ] **Step 4: Offline-Tests grün**

- [ ] **Step 5: Im Spiel prüfen** (Blinkii): Checks `PortraitSetup fired`, `PortraitsLoaded fired`, `portrait.key set`, `portrait.plugins table` grün. Target wechseln → `PortraitUnitChanged` und `PortraitUpdated` im Chat. Profilwechsel → `ProfileChanged`.

- [ ] **Step 6: stylua, luacheck, commit** `"Fire plugin callbacks over the portrait lifecycle"`

---

### Task 3: Frame-Provider-Registry, eingebaute Integrationen umziehen

**Files:**
- Create: `Blinkiis_Portraits/portraits/providers.lua` (ersetzt `portraits/unitframes.lua`, die alte Datei wird entfernt, `load_portraits.xml` angepasst)
- Modify: `Blinkiis_Portraits/core.lua` (`ADDON_FOLDERS` und `CheckAddons` lesen aus der Registry)
- Modify: `Blinkiis_Portraits/portraits/functions.lua` (`ufTypePriority`, `GetUnitFrame`, `GetUnitFrames`, `GetUnitFrameName`, `GetFrameUnit`)
- Modify: `Blinkiis_Portraits/portraits/party.lua` (`ResolvePartyParent` über die Provider-Funktion, BBF als Funktion)
- Modify: `Blinkiis_Portraits/options.lua` (`parentFrames` wird eine Funktion über die Registry, an allen 8 Stellen `values = parentFrames`)
- Modify: `Blinkiis_Portraits/report.lua`, falls dort Provider fest aufgezählt sind
- Create: `tests/test_providers.lua`
- Modify: `examples/BP_ExamplePlugin/`

**Interfaces:**
- Consumes: `API`, `PortraitsLoaded`
- Produces:
  - `API:RegisterFrameProvider(id: string, def: {label: string, addons: string[], units: {[unit]: string | function(index?) -> frame}, unitRestriction?: string, getUnit?: function(frame) -> unit, priority?: number}) -> boolean`
  - intern `BLINKIISPORTRAITS:GetProviders() -> sortierte Liste`, `BLINKIISPORTRAITS:GetProvider(id)`, `BLINKIISPORTRAITS:RefreshProviderAvailability()` (von `CheckAddons` aufgerufen)
  - `GetUnitFrames(unit, setting)` behält Signatur und Rückgabe (`frameNameOrFrame, providerOptionValue`)
  - Flags (`BLINKIISPORTRAITS.ELVUI` usw.) und `LoadedAddons` bleiben für bestehende Sonderfälle (SUF-Hooks, EQOL) erhalten.
  - Eingebaute Prioritäten, unverändert: df (party) 10, cell (party, Flag Cell) 20, elvui 30, pb4 40, suf 50, uuf 60, ndui 70, cell_uf 80, eqol 90, bbf 100, eui 110, stuf 120. Plugin-Provider ohne `priority` bekommen 1000 und folgende in Registrierungsreihenfolge.
  - Gespeichertes `"cell"` in `profile.<unit>.unitframe` bedeutet weiter Cell und Cell_UF: zwei interne Einträge mit `optionValue = "cell"`, im Dropdown ein Wert.

- [ ] **Step 1: `tests/test_providers.lua` schreiben**

```lua
local BP = newBP({ "api.lua", "portraits/providers.lua" })
_G.ElvUF_Player = {}; _G.SUFUnitplayer = {}; _G.MyUF_Player = {}
setLoadedAddons({ "ElvUI", "ShadowedUnitFrames", "MyUF" }); BP:RefreshProviderAvailability()
eq(select(2, BP:GetUnitFrames("player", "auto")), "elvui", "auto keeps builtin priority")
eq(select(2, BP:GetUnitFrames("player", "suf")), "suf", "explicit setting wins")
truthy(BP.API:RegisterFrameProvider("myuf", { label = "My UF", addons = { "MyUF" }, units = { player = "MyUF_Player" } }), "plugin provider registered")
eq(BP.API:RegisterFrameProvider("myuf", { label = "x", addons = {}, units = {} }), false, "duplicate rejected")
setLoadedAddons({ "MyUF" }); BP:RefreshProviderAvailability()
eq(select(2, BP:GetUnitFrames("player", "auto")), "myuf", "plugin provider used when alone")
eq(select(2, BP:GetUnitFrames("player", "gone")), "myuf", "unknown saved provider behaves like auto")
setLoadedAddons({ "Cell" }); BP:RefreshProviderAvailability(); _G.CellPartyFrameHeaderUnitButton1 = {}
eq(select(2, BP:GetUnitFrames("party", "cell")), "cell", "cell party via flag Cell")
eq(BP:GetUnitFrames("player", "cell"), nil, "Cell alone has no player frame")
truthy(BP:GetProvider("pb4") and type(BP:GetProvider("pb4").units.player) == "function", "pb4 resolves at runtime")
```

- [ ] **Step 2: Ausführen, Fehlschlag prüfen**

- [ ] **Step 3: Umsetzen**

Alle 12 Einträge aus `unitframes.lua` und `ufTypePriority` werden über dieselbe interne Registrierfunktion eingetragen wie Plugin-Provider. Die Strings in `units` behalten ihre heutige Bedeutung: globaler Name oder Punkt-Pfad, bei Gruppen der Basisname plus Index. PitBull4 und BBF-Party werden Funktionen, `partyself` bleibt ein normaler Unit-Schlüssel. `GetUnitFrames` behält beide Durchläufe und sortiert nach `priority`. `getUnit` wird in `GetFrameUnit` zuerst gefragt, wenn der Provider des Portraits eines hat.

- [ ] **Step 4: Offline-Tests grün**

- [ ] **Step 5: Im Spiel prüfen** (Blinkii):
  - ElvUI, SUF, Cell (Party, 5er-Gruppe) und PitBull4 jeweils allein: Portraits an denselben Frames wie auf `main`, `/bp report` unverändert.
  - Beispiel-Plugin erstellt `BPEX_PlayerFrame` (100×40, sichtbar, `unit = "player"`) und registriert ihn als Provider. Mit allen UF-Addons aus hängt das Player-Portrait daran.
  - Review Focus 2: `/run BLINKIISPORTRAITS.db.profile.player.unitframe = "gone"; BLINKIISPORTRAITS:LoadPortraits()` → kein Fehler, das Dropdown zeigt leer.

- [ ] **Step 6: stylua, luacheck, commit** `"Resolve unit frames through a frame provider registry"`

---

### Task 4: Media-Registries

**Files:**
- Modify: `Blinkiis_Portraits/api.lua`
- Modify: `Blinkiis_Portraits/options.lua` (`form` und die `values` der Klassen- und Spec-Icon-Auswahl werden aus `BLINKIISPORTRAITS.media` plus Registry gebaut, wo sie heute fest sind)
- Modify: `Blinkiis_Portraits/portraits/functions.lua` (`UpdateTexturesFiles` nutzt `ResolveStyle`)
- `api.lua` bekommt intern `BLINKIISPORTRAITS:ResolveStyle(id, defaultId) -> styleTable, resolvedId`: Ein unbekannter Style fällt auf `defaultId` zurück (die Voreinstellung aus `defaults.lua` für diese Unit).
- Create: `tests/test_media.lua`
- Modify: `examples/BP_ExamplePlugin/` (ein Style und ein Icon-Set, die BP-eigene Dateien wiederverwenden, keine neuen Texturen)

**Interfaces:**
- Consumes: `API`, `PortraitsLoaded`
- Produces:
  - `API:RegisterStyle(id, {name: string, texture, mask, extra?, mask_mirror?, extra_mirror?}) -> boolean` → `BLINKIISPORTRAITS.media.portraits[id]`
  - `API:RegisterClassIconSet(id, {name, texture, texCoords: {[CLASS]: 8 numbers}}) -> boolean` → `media.class[id]`
  - `API:RegisterSpecIconSet(id, {name, texture, texCoords: {[specID]: 8 numbers}}) -> boolean` → `media.spec[id]`, ohne `SpecIconsSupported` → `false`
  - `API:Refresh()`: `LoadPortraits` (mit Combat-Retry) und `NotifyChange`
  - Bereits vorhandene IDs (auch eingebaute) → `false`. Fehlen Pflichtfelder (`name`, `texture`, bei Styles `mask`) → `false`.
  - Registrierungen nach dem ersten `PortraitsLoaded` lösen gebündelt genau einmal `API:Refresh()` aus (`C_Timer.After(0, ...)`).

- [ ] **Step 1: `tests/test_media.lua` schreiben**

```lua
local BP = newBP({ "api.lua" }); BP.media = { portraits = { antik = { texture = "a", mask = "m" } }, class = {}, spec = {} }
local refreshes = 0; BP.LoadPortraits = function() refreshes = refreshes + 1 end
truthy(BP.API:RegisterStyle("s1", { name = "S1", texture = "t", mask = "m" }), "style registered")
eq(BP.media.portraits.s1.texture, "t", "style lands in media")
eq(BP.API:RegisterStyle("antik", { name = "x", texture = "t", mask = "m" }), false, "builtin id rejected")
eq(BP.API:RegisterStyle("s2", { name = "S2", texture = "t" }), false, "missing mask rejected")
BP.SpecIconsSupported = false
eq(BP.API:RegisterSpecIconSet("sp", { name = "Sp", texture = "t", texCoords = {} }), false, "spec sets need spec support")
BP:Fire("PortraitsLoaded")
BP.API:RegisterStyle("s3", { name = "S3", texture = "t", mask = "m" }); BP.API:RegisterStyle("s4", { name = "S4", texture = "t", mask = "m" })
flushTimers(); eq(refreshes, 1, "late registrations refresh once")
setCombat(true); BP.API:RegisterStyle("s5", { name = "S5", texture = "t", mask = "m" }); flushTimers()
truthy(BP.media.portraits.s5, "registration works in combat")
```
```lua
eq(select(2, BP:ResolveStyle("missing", "antik")), "antik", "unknown style falls back to default")
eq(select(2, BP:ResolveStyle("s1", "antik")), "s1", "registered style resolves")
```

- [ ] **Step 2: Ausführen, Fehlschlag prüfen** · **Step 3: umsetzen** · **Step 4: Offline-Tests grün**

- [ ] **Step 5: Im Spiel prüfen** (Blinkii): „BPEX Round“ in der Style-Liste, wählbar. Review Focus 5: Style wählen, Beispiel deaktivieren, `/reload` → Voreinstellung, kein Fehler. Review Focus 1: im Kampf `/run BLINKIISPORTRAITS.API:RegisterStyle(...)` → kein Taint, nach dem Kampf in der Liste.

- [ ] **Step 6: stylua, luacheck, commit** `"Let plugins register portrait styles and icon sets"`

---

### Task 5: Export und Import mit Plugin-Einstellungen

**Files:**
- Modify: `Blinkiis_Portraits/options.lua` (`exportProfile`, `ReadImportString`, `ImportProfile`, `BuildImportDisplay`), dabei die Logik in `Blinkiis_Portraits/profile_io.lua` auslagern (neue Datei in allen TOCs vor `options.lua`), damit sie ohne AceGUI testbar ist
- Modify: `Blinkiis_Portraits/Locales/enUS.lua`
- Create: `tests/test_profile_io.lua`, `tests/fixtures/legacy_export.lua` (eine Lua-Tabelle, wie `DecodeProfile` sie heute aus einem echten Export von `main` liefert; Blinkii erzeugt den String vor Beginn, der Umsetzer wandelt ihn im Spiel per `/run` um oder baut die Tabelle aus `defaults.lua` nach)

**Interfaces:**
- Consumes: `API:IteratePlugins`, `plugin.db`
- Produces:
  - `BLINKIISPORTRAITS:BuildExportData(meta: {author, name, version}) -> table` mit `profile` und, nur wenn Plugins registriert sind, `plugins = { [pluginName] = <Namespace-Profil> }`
  - `BLINKIISPORTRAITS:ApplyImport(profileName, data) -> skippedPluginNames: string[]` (schreibt `data.profile` wie heute `ImportProfile`, dann pro registriertem Plugin die Werte in dessen Namespace für `profileName`, dann `SetProfile`)
  - String `L["Skipped settings of plugins that are not loaded: %s"]`

- [ ] **Step 1: `tests/test_profile_io.lua` schreiben**

```lua
local BP = newBP({ "api.lua", "profile_io.lua" })
local p = BP.API:NewPlugin("P1", { apiVersion = 1, defaults = { profile = { marker = 0 } } })
p.db.profile.marker = 42
local data = BP:BuildExportData({ name = "X" })
eq(data.plugins.P1.marker, 42, "export carries loaded plugin")
local BP2 = newBP({ "api.lua", "profile_io.lua" })
eq(BP2:BuildExportData({ name = "X" }).plugins, nil, "no plugins, no field")
data.plugins.NotLoaded = { x = 1 }
local skipped = BP:ApplyImport("Imported", data)
eq(skipped[1], "NotLoaded", "unloaded plugin skipped")
eq(BP.db.sv.namespaces and BP.db.sv.namespaces.NotLoaded, nil, "skipped data not stored")
eq(p.db.profile.marker, 42, "plugin values imported into new profile")
local legacy = dofile("tests/fixtures/legacy_export.lua")
eq(#BP:ApplyImport("Legacy", legacy), 0, "legacy string imports without plugin notice")
BP.db:CopyProfile("Imported"); eq(p.db.profile.marker, 42, "copy profile carries namespace")
```

- [ ] **Step 2: Ausführen, Fehlschlag prüfen** · **Step 3: umsetzen** · **Step 4: Offline-Tests grün**

- [ ] **Step 5: Im Spiel prüfen** (Blinkii): echten Export-String von `main` importieren → Profil identisch zu vorher. Export mit Beispiel-Plugin, Plugin deaktivieren, importieren → Meldung nennt `BP_ExamplePlugin`.

- [ ] **Step 6: stylua, luacheck, commit** `"Carry loaded plugins' settings through profile export and import"`

---

### Task 6: Element-Runner und erstes Element (Desaturate)

**Files:**
- Create: `Blinkiis_Portraits/portraits/elements.lua` (in `load_portraits.xml` vor `functions.lua`)
- Modify: `Blinkiis_Portraits/portraits/functions.lua` (`UpdateDesaturated` wird das Update des Elements `Desaturate`, Aufrufer gehen über den Runner)
- Create: `tests/test_elements.lua`

**Interfaces:**
- Produces (zunächst intern, öffentlich in Task 9):
  - `BLINKIISPORTRAITS:DefineElement(name, def: {events?: string[], Enable?: fn(element, portrait) -> boolean, Disable?: fn(element, portrait), Update: fn(element, portrait, event, unit) -> ...results})`
  - `BLINKIISPORTRAITS:RunElement(portrait, name, event, unit)`: alle `PreUpdate(element, portrait, unit)`, dann `Override(element, portrait, event, unit)` oder `Update`, dann alle `PostUpdate(element, portrait, unit, ...results)`. Ohne Hooks ein direkter Aufruf von `Update`, ohne Tabellen und ohne Varargs-Packing.
  - `BLINKIISPORTRAITS:HookElementInternal(pluginName, name, hooks: {PreUpdate?, PostUpdate?, Override?, events?}) -> boolean, errorString`
  - `API:UpdateElement(portrait, name)` (öffentlich) = `RunElement(portrait, name, "UpdateElement", portrait.unit)`
  - `portrait.elements[name]` = Zustand pro Portrait. Ergebnis von `Desaturate`: `isDesaturated: boolean`.

- [ ] **Step 1: `tests/test_elements.lua` schreiben**

```lua
local BP = newBP({ "api.lua", "portraits/elements.lua" })
local order = {}
BP:DefineElement("E", { Update = function() order[#order + 1] = "update"; return 7 end })
local portrait = { unit = "player", elements = {} }
BP:HookElementInternal("A", "E", { PreUpdate = function() order[#order + 1] = "pre" end, PostUpdate = function(_, _, _, r) order[#order + 1] = "post" .. r end })
BP.API:UpdateElement(portrait, "E")
eq(table.concat(order, ","), "pre,update,post7", "pre, update, post with result")
order = {}
truthy(BP:HookElementInternal("A", "E", { Override = function() order[#order + 1] = "override" end }), "first override accepted")
eq(BP:HookElementInternal("B", "E", { Override = function() end }), false, "second override rejected")
truthy(BP.printed[#BP.printed]:find("A") and BP.printed[#BP.printed]:find("B"), "warning names both plugins")
BP.API:UpdateElement(portrait, "E")
eq(table.concat(order, ","), "pre,override,post", "override replaces update")
BP:HookElementInternal("C", "E", { PostUpdate = function() error("boom") end })
BP:HookElementInternal("D", "E", { PostUpdate = function() order.after = true end })
BP.API:UpdateElement(portrait, "E")
truthy(order.after, "failing hook does not stop later hooks")
```

- [ ] **Step 2: Ausführen, Fehlschlag prüfen** · **Step 3: umsetzen** (Hooks über `BLINKIISPORTRAITS:SafeCall`, eingebautes `Update` direkt) · **Step 4: Offline-Tests grün**

- [ ] **Step 5: Im Spiel prüfen** (Blinkii): „Force desaturate“ und tote Units sehen aus wie auf `main`. Review Focus 3: Beispiel hängt `PostUpdate = function() error("boom") end` an `Desaturate`, Target wechseln → Portrait korrekt, Fehler in BugSack.

- [ ] **Step 6: stylua, luacheck, commit** `"Add the portrait element runner and move desaturation onto it"`

---

### Task 7: Elemente Color und Extra

**Files:**
- Modify: `Blinkiis_Portraits/portraits/functions.lua` (`Update`: Farbe und Extra über `RunElement`, `UpdateExtraTexture`; `GetUnitColor` bleibt Helfer)
- Modify: `tests/test_elements.lua`, `examples/BP_ExamplePlugin/checks.lua`

**Interfaces:**
- Consumes: Task 6
- Produces: Ergebnis `Color` → `color` (die Farbtabelle für `SetColor`, Felder `r, g, b, a`, auf Retail möglicherweise geheim). Ergebnis `Extra` → `classification: string | nil`. Extra liest die Farbe aus `portrait.elements.Color.color` statt über einen Parameter.

- [ ] **Step 1: Offline-Test ergänzen:** Ein Override auf `Color`, der `portrait.elements.Color.color` auf `{ r = 1, g = 0, b = 0 }` setzt, danach `RunElement(portrait, "Extra", ...)` mit einem nachgebauten `Extra`-Update, das `portrait.elements.Color.color` liest → `eq(seenColor.r, 1, "extra sees overridden color")`.
- [ ] **Step 2–4: fehlschlagen, umsetzen, Offline-Tests grün**
- [ ] **Step 5: Im Spiel prüfen** (Blinkii): Check `Color PostUpdate gets table`. Override macht den Player-Rahmen rot, Extra sitzt weiter richtig. Rare-, Elite- und Boss-Extra, `unitcolor` an und aus wie auf `main`. Review Focus 4: Retail, Gegner in einer Instanz → kein „attempt to compare secret“ aus BP, `PostUpdate` läuft.
- [ ] **Step 6: stylua, luacheck, commit** `"Move portrait color and extra texture onto elements"`

---

### Task 8: Elemente Portrait, Frame, Cast, Ring

**Files:**
- Modify: `Blinkiis_Portraits/portraits/functions.lua`:
  - `UpdatePortrait`, `GetUnitIcon`, `Mirror`-Aufruf → `Portrait`
  - `UpdateTextures`, `UpdateTexturesFiles`, `UpdateSize`, `UpdateZoom` → `Frame`
  - `CastStart`, `CastStop` → `Cast`
  - `CreateRing`, `UpdateRing*` → `Ring`
- Modify: `examples/BP_ExamplePlugin/checks.lua`

**Interfaces:**
- Consumes: Task 6
- Produces, Ergebnisse für `PostUpdate`:
  - `Portrait` → `texture` (Pfad, Datei-ID oder nil bei `SetPortraitTexture`), `texCoords | nil`
  - `Frame` → `texturePath`, `maskPath`
  - `Cast` → `castIcon | nil` (nil, wenn der Cast endet)
  - `Ring` → `value`, `maxValue` (möglicherweise geheim), `mode` (`"health"`, `"cast"` oder nil)

  `RetryPortrait` und „Textur behalten, solange das Modell nicht bereit ist“ bleiben im eingebauten `Update` von `Portrait`.

- [ ] **Step 1: Offline:** Der Runner selbst ist durch Task 6 abgedeckt. Diese Elemente sind Frame-Code, deshalb gibt es hier keinen neuen Offline-Test. `tests/run.lua` muss trotzdem grün bleiben.
- [ ] **Step 2: Umsetzen**, ein Element nach dem anderen, nach jedem Element `tests/run.lua` und ein `/reload` im Spiel.
- [ ] **Step 3: Im Spiel prüfen** (Blinkii): je Element ein `PostUpdate`-Check im Selbsttest (`Ring`: im Health-Modus `value ~= nil` nach Schaden). Dazu die Regression:
  - Portrait, Klassen-Icon, Spec-Icon (Retail), JiberishIcons-Pack
  - Spiegeln an und aus
  - Fahrzeug betreten und verlassen
  - Cast mit Cast-Icon, Empower (Retail)
  - Ring Health und Cast
  - Party 5er-Gruppe mit Rollentausch
  - Demo-Modus SUF
- [ ] **Step 4: stylua, luacheck, commit** `"Move portrait, frame, cast and ring onto elements"`

---

### Task 9: Elemente öffentlich (RegisterElement, HookElement)

**Files:**
- Modify: `Blinkiis_Portraits/api.lua`, `Blinkiis_Portraits/portraits/elements.lua`, `Blinkiis_Portraits/portraits/functions.lua` (`OnEvent` und `RegisterEvents` routen Element-Events, `SetupUnitPortrait` ruft `Enable` und `Disable`)
- Modify: `tests/test_elements.lua`

**Interfaces:**
- Consumes: Task 6 bis 8
- Produces:
  - `API:RegisterElement(plugin, name, def: {events?, Enable, Disable?, Update}) -> boolean, errorString` (eingebaute und doppelte Namen abgelehnt)
  - `API:HookElement(plugin, name, hooks: {PreUpdate?, PostUpdate?, Override?, events?}) -> boolean, errorString`
  - intern `BLINKIISPORTRAITS:BuildElementRouting(portrait)` → `portrait.elementEvents = { [event] = { elementName, ... } }`, neu gebaut bei `PortraitSetup`, nie pro Event. Jedes Event wird pro Portrait einmal angemeldet (`UNIT_*` auf die Unit gefiltert). Events aus `hooks.events` lösen nur `RunElement` für dieses Element aus, ohne den zentralen Zustandscheck in `Update`.
  - `Enable` läuft bei jedem `SetupUnitPortrait`. `false` → `Disable` und Abmelden der Events, die kein anderes Element dieses Portraits braucht.

- [ ] **Step 1: Offline-Tests ergänzen**

```lua
truthy(BP.API:RegisterElement(plugin, "X", { events = { "UNIT_HEALTH" }, Enable = function() return true end, Update = noop }), "element registered")
eq(BP.API:RegisterElement(plugin, "Ring", { Enable = noop, Update = noop }), false, "builtin name rejected")
BP.API:HookElement(plugin, "Color", { events = { "UNIT_HEALTH", "UNIT_POWER_UPDATE" }, PostUpdate = noop })
BP:BuildElementRouting(portrait)
eq(table.concat(portrait.elementEvents.UNIT_HEALTH, ","), "Color,X", "UNIT_HEALTH routes to both, sorted by name")
eq(#portrait.elementEvents.UNIT_POWER_UPDATE, 1, "hook events routed")
BP.API:RegisterElement(plugin, "Y", { events = { "UNIT_AURA" }, Enable = function() return false end, Update = noop })
BP:BuildElementRouting(portrait)
eq(portrait.elementEvents.UNIT_AURA, nil, "disabled element routes nothing")
```
- [ ] **Step 2–4: fehlschlagen, umsetzen, Offline-Tests grün**
- [ ] **Step 5: Im Spiel prüfen** (Blinkii): Zähler-Element auf `UNIT_HEALTH` zählt bei Schaden hoch, die Option im Plugin-Tab hält es an.
- [ ] **Step 6: stylua, luacheck, commit** `"Open elements to plugins"`

---

### Task 10: Machbarkeitstests im Beispiel-Plugin, API-Lücken schließen

**Files:**
- Create: `examples/BP_ExamplePlugin/healthfill.lua`, `examples/BP_ExamplePlugin/ring2.lua`
- Create: `tests/test_example_api_only.lua`
- Modify: `Blinkiis_Portraits/api.lua` und betroffene Dateien, nur für Lücken, die die Tests aufdecken

**Interfaces:**
- Consumes: alle öffentlichen APIs
- Produces: zwei Plugin-Features, die **nur** öffentliche API und die stabilen Portrait-Felder nutzen

- [ ] **Step 1: `tests/test_example_api_only.lua` schreiben:** liest alle `.lua` in `examples/BP_ExamplePlugin/` als Text. Prüft, dass `BLINKIISPORTRAITS` nur als `BLINKIISPORTRAITS.API` vorkommt und `portrait.<feld>` nur Felder aus der stabilen Liste plus `plugins` und `elements` nutzt (Muster-Suche). Erwartet zunächst grün mit dem bisherigen Beispiel.
- [ ] **Step 2: `healthfill.lua`** Eigene Textur über `portrait.portrait`, gleiche Maske (`portrait.mask`), vertikale Füllung nach HP, der fehlende Teil abgedunkelt. Auslöser: `HookElement(plugin, "Portrait", { events = { "UNIT_HEALTH", "UNIT_MAXHEALTH" }, PostUpdate = ... })`. Auf Retail über eine vertikale StatusBar (`SetValue` nimmt geheime Werte) statt Rechnen mit HP.
- [ ] **Step 3: `ring2.lua`** `RegisterElement(plugin, "BPEX_Ring2", ...)`: zweiter Radial-Ring für Power innerhalb des BP-Rings, gleiche Textur wie `portrait.ring`, eigene Größe. Ohne Radial-Render-Mode deaktiviert sich das Element über `Enable`.
- [ ] **Step 4: Offline-Tests grün** (der Test aus Step 1 schlägt an, wenn eines der Features interne Felder nutzt)
- [ ] **Step 5: Im Spiel prüfen** (Blinkii) auf Retail (Instanz mit geheimen Werten) und Forever: beide Features sichtbar und korrekt, keine Fehler.
- [ ] **Step 6: Lücken schließen** Jede Lücke wird als öffentliche Funktion oder neues stabiles Feld ergänzt, mit Offline-Test, falls es Logik ist. Gibt es keine, bleibt der Schritt leer.
- [ ] **Step 7: stylua, luacheck, commit** `"Prove the plugin API with a health fill and a second ring"`

---

### Task 11: Doku, Changelog, Release-Vorbereitung

**Files:**
- Create: `docs/plugin-api.md` (Referenz: alle Funktionen aus `api.lua` mit Signaturen, Callbacks mit Argumenten, Element-Ergebnisse aus Task 6 bis 8, stabile Portrait-Felder, Hinweise zu Secret Values und Combat Lockdown, EllesmereUI-Optionstypen, Export-Regel)
- Modify: `README.md` (Abschnitt „Plugins“ mit Link, Abschnitt „Tests“ mit dem Aufruf `D:\Dev\tools\lua51\lua.exe tests/run.lua` bzw. allgemein „Lua 5.1“)
- Modify: `CHANGELOG.md` (über den Skill `wow-addon-changelog`, Eintrag unter NEW)
- Modify: `Blinkiis_Portraits/Locales/enUS.lua` (alle neuen Strings vorhanden)
- Modify: `.github/workflows/*.yml`, nur prüfen: `tests/`, `examples/` und `docs/` dürfen nicht ins Zip (sie liegen außerhalb von `Blinkiis_Portraits/`, das sollte schon so sein)

- [ ] **Step 1: Doku schreiben** und gegen `api.lua` abgleichen: jede öffentliche Funktion dokumentiert, keine dokumentierte Funktion fehlt.
- [ ] **Step 2: Offline-Tests komplett grün**
- [ ] **Step 3: Vollständiger Regressionstest im Spiel** (Blinkii) ohne Beispiel-Plugin auf Retail und einem Classic-Flavor mit ElvUI, SUF und Cell: Verhalten wie auf `main`. Danach mit Beispiel: `/bpex test` grün.
- [ ] **Step 4: commit** `"Document the plugin API"`. Danach entscheidet Blinkii über Merge und Release.
