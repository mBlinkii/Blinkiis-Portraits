# Plugin-API für Blinkiis Portraits – Design

Stand: 21.11.2026 · Status: Entwurf zur Freigabe

## Absicht und Warum

Blinkiis Portraits (BP) bleibt ein reines Portrait-Addon, das sich an fremde Unitframe-Addons hängt. Anlass ist Sashs „VuppEdit“: ein Fork, der BP zu einem eigenständigen Unitframe-Addon ausbaut (eingebettetes oUF, Texte, Auren, Portrait als Healthbar, Ring 2, neue Styles). Blinkii will davon nichts in BP übernehmen, aber solche Erweiterungen sollen als **eigene Addons (Plugins)** möglich sein, über einen stabilen, dokumentierten Vertrag statt durch Überschreiben interner Funktionen am globalen `BLINKIISPORTRAITS`.

Erfolg heißt: Sashs Edit ließe sich komplett als separates Plugin bauen (eigene Frames als Provider, eigene Elemente, Eingriff in Farbe/Füllung/Textur), ohne dass BP selbst Unitframe-Features enthält und ohne dass jedes BP-Update das Plugin bricht.

## Ziele

Plugins können:

1. **Frame-Provider** registrieren („für Unit X ist mein Frame Y“), damit BP Portraits an ihre Frames hängt.
2. **Styles, Klassen-Icon-Sets und Spec-Icon-Sets** registrieren, die in den BP-Optionen auswählbar sind.
3. **Eigene Elemente** an Portraits hängen (Texte, Auren, zusätzliche Ringe, Overlays) und über BPs Event-System aktualisieren.
4. **In BPs eigene Elemente eingreifen** (Farbe, Rahmen-Textur, Füllung/Maske, Ring, Cast, Entsättigung): vorher, nachher oder komplett ersetzen.
5. Auf **Lebenszyklus-Events** reagieren (Portrait erstellt, eingerichtet, Unit gewechselt, aktualisiert, entfernt, Profil gewechselt).
6. Einen **eigenen Tab** in den BP-Optionen und **eigene Einstellungen pro Profil** haben.

## Nicht-Ziele

- BP liefert selbst keine Unitframes, Texte, Auren oder Blizzard-Frame-Ersatz aus.
- Kein Sandboxing: Plugins laufen mit denselben Rechten wie jedes Addon.
- Keine Plugin-Verwaltung in der UI (kein Aktivieren/Deaktivieren in BP, das macht die Addon-Liste des Spiels).

## Anti-Ziele (wäre ein Fehlschlag, auch wenn es technisch läuft)

- **Code 1:1 aus anderen Addons kopiert** (oUF, ElvUI, Sashs Edit). oUF dient nur als Vorbild für das Muster Element + PreUpdate/Override/PostUpdate. Die Implementierung ist eigener Code im BP-Stil.
- Bestehende Profile oder Import-Strings ändern ihr Verhalten.
- Spürbar mehr Last pro Event, wenn kein Plugin geladen ist.
- Sichtbare Verhaltensänderung von BP ohne Plugins nach irgendeiner Umbau-Phase.
- Ein fehlerhaftes Plugin legt BPs eigene Portraits lahm.

## Rahmenbedingungen

- Nur ein Global: `BLINKIISPORTRAITS`. Konventionen laut `stylua.toml` (Tabs, Breite 200, doppelte Anführungszeichen, Klammern bei jedem Aufruf), kaum Kommentare, einzeilig und englisch.
- Keine neuen Libraries. CallbackHandler-1.0 und AceDB-3.0 sind schon in `libs/embeds.xml`.
- Alle Flavors (Mainline, Camelot/Forever, Mists, TBC, Vanilla, Wrath). Neue Dateien in alle TOCs.
- Secret Values in 12.x: Plugins können geheime Werte bekommen. Die API gibt sie unverändert weiter und bietet die vorhandenen Helfer an.
- Combat Lockdown: Erstellen, Ankern und Setzen sicherer Attribute bleiben hinter dem bestehenden Retry in `LoadPortraits`.
- Keine Allokationen pro Event im Hot Path.

## Ansätze

| | Ansatz | Abwägung |
|---|---|---|
| 1 | **Filter an festen Stellen** (`RegisterFilter("Color", fn)`) | Kleiner Umbau, kurze Liste. Aber Plugins können nur ändern, was als Filter vorgesehen ist. „Portrait als Healthbar“ braucht Maske und Zeichenebenen, das ist so kaum abbildbar. |
| 2 | **Elemente nach oUF-Vorbild** (je Teil Enable/Update plus PreUpdate/Override/PostUpdate, Plugins registrieren eigene Elemente) | Deckt Dazubauen und Eingreifen einheitlich ab, WoW-Autoren kennen das Muster. Aber echter Umbau der Engine in `portraits/functions.lua` mit Risiko für Regressionen. |
| 3 | **Nur dokumentieren plus `hooksecurefunc`** | Fast kein Aufwand. Aber jede Umbenennung bricht Plugins, Override ist praktisch unmöglich. |

**Gewählt: Ansatz 2** (Blinkii, 21.11.2026). Begründung: Plugins sollen ausdrücklich auch in BPs Zeichnen eingreifen können („B“), und nur das Element-Modell bietet dafür einen sauberen Weg. Der Umbau passiert Element für Element, BP verhält sich nach jedem Schritt unverändert. Registries, Callbacks, Optionen und Namespaces gehören zu allen drei Ansätzen und sind Teil des Designs.

## Design

### Öffentlicher Einstieg

- Die API liegt in `BLINKIISPORTRAITS.API`. Nur was dort und in diesem Dokument steht, ist öffentlich und stabil. Alles andere am globalen `BLINKIISPORTRAITS` bleibt intern. *(Eigene Entscheidung: trennt Vertrag und Interna sichtbar.)*
- `API.version`: eine Ganzzahl. Hinzufügen ändert sie nicht, ein Bruch erhöht sie.
- Plugins setzen `## Dependencies: Blinkiis_Portraits` in ihrer TOC, damit BP immer zuerst geladen ist.

### Plugin-Registrierung

```lua
local plugin = BLINKIISPORTRAITS.API:NewPlugin("BP_Example", {
	apiVersion = 1,
	defaults = { profile = { ... } },
	options = function() return aceConfigGroup end,
})
```

- `plugin.db` ist ein AceDB-Namespace (`BP.db:RegisterNamespace(name, defaults)`): Er wechselt mit dem BP-Profil und berührt `db.profile` von BP nicht.
- `options` wird als eigener Unter-Tab in einem Tab **„Plugins“** der BP-Optionen eingehängt. In der ElvUI-Variante (`elvui.lua`) erscheint er automatisch, weil sie dieselben `args` teilt. Die EllesmereUI-Variante (`eui.lua`) registriert heute einmalig in `OnInitialize`. Sie wird bei jeder Plugin-Registrierung neu aufgebaut. Die Doku nennt die Optionstypen, die EllesmereUI darstellt: group, header, description, toggle, range, select, color, execute, input. *(Eigene Entscheidung.)*
- Passt `apiVersion` nicht zu `API.version`, druckt BP eine Warnung und lehnt das Plugin ab.
- Ein Name darf nur einmal registriert werden.
- **Profil-Export, -Import und -Kopieren nehmen Plugin-Einstellungen mit** (Blinkii, 21.11.2026). Der Export-String bekommt ein zusätzliches Feld, aber **nur für Plugins, die aktiviert und geladen sind** und sich per `NewPlugin` registriert haben (Blinkii, 21.11.2026). Beim Import gilt dasselbe: Einstellungen für ein Plugin, das gerade nicht geladen ist, werden übersprungen und nicht gespeichert. Der Import meldet die übersprungenen Plugins. Strings ohne dieses Feld importieren genau wie heute. Beim Kopieren eines Profils kopiert BP die Namespaces der geladenen Plugins mit.

### Callbacks

Über CallbackHandler-1.0 an `API`: `API.RegisterCallback(self, "PortraitCreated", handler)`.

| Event | Argumente | Wann |
|---|---|---|
| `PortraitCreated` | portrait | Frame wurde neu erstellt (`CreatePortrait`) |
| `PortraitSetup` | portrait | nach jedem `SetupUnitPortrait` (neuer Parent, Profil, Optionen) |
| `PortraitUnitChanged` | portrait, unit | aufgelöste Unit hat gewechselt |
| `PortraitUpdated` | portrait, event | nach einem Update mit Zustandsänderung (nicht bei jedem Event) |
| `PortraitRemoved` | portrait | `RemovePortrait` / `KillPortrait` |
| `PortraitsLoaded` | – | Ende von `LoadPortraits` |
| `ProfileChanged` | – | AceDB-Profil gewechselt, kopiert oder zurückgesetzt |

Ohne Abonnenten soll ein Callback praktisch nichts kosten. CallbackHandler bricht bei Fehlern einzelner Handler die Schleife nicht ab.

### Frame-Provider-Registry

```lua
API:RegisterFrameProvider("myuf", {
	label = "My Unit Frames",
	addons = { "MyUnitFrames" },
	units = {
		player = "MyUF_Player",
		party = function(index) return _G["MyUF_Party" .. index] end,
	},
	getUnit = function(frame) return frame.myUnit end,
})
```

- Ersetzt die drei fest verdrahteten Stellen: `ADDON_FOLDERS` (`core.lua`), `ufTypePriority` (`portraits/functions.lua`) und `BLINKIISPORTRAITS.unitFrames` (`portraits/unitframes.lua`), dazu die Werteliste der Option `unitframe`.
- **Die eingebauten Integrationen (ElvUI, Cell, SUF, PB4, UUF, NDui, EQOL, BBF, EUI, Stuf, DandersFrames) werden selbst über diese Registry eingetragen.** Ihre Priorität bleibt genau wie heute. Das ist der Praxistest der API.
- Ein Unit-Eintrag ist entweder ein String (globaler Name oder Punkt-Pfad wie heute, bei Gruppen der Basisname, an den der Index angehängt wird) oder eine Funktion, die den Frame liefert. Optional `unitRestriction` (heute `unit = "party"` bei Cell und DandersFrames).
- `getUnit` ist optional und ergänzt `GetFrameUnit`, wenn ein Addon die Unit anders ablegt.
- Plugin-Provider kommen in der Auto-Priorität **nach** den eingebauten, außer sie geben `priority` an.
- Sonderfälle bleiben intern und laufen über dieselbe Form: PitBull4 (dynamische Namen, also Funktion), BBF-Party (`PartyFrame[...]`, also Funktion), `partyself`.

### Media-Registries

```lua
API:RegisterStyle("mystyle", { name = "My Style", texture = ..., mask = ..., extra = ..., mask_mirror = ..., extra_mirror = ... })
API:RegisterClassIconSet("myicons", { name = "My Icons", texture = ..., texCoords = { WARRIOR = {...}, ... } })
API:RegisterSpecIconSet("myspec", { ... })
```

- Gleiche Form wie die Einträge in `media/media.lua`, sie landen in denselben Tabellen und tauchen in den Auswahllisten auf.
- `RegisterSpecIconSet` hat nur auf Retail eine Wirkung (`SpecIconsSupported`).
- Kommt eine Registrierung nach dem ersten `LoadPortraits`, lädt BP die Portraits neu und aktualisiert die offenen Optionen.
- Ein gewählter Style, den es nicht mehr gibt, fällt auf die Voreinstellung zurück. Das funktioniert heute schon so für gelöschte Custom- und JiberishIcons-Packs.

### Elemente

Jedes Portrait besteht aus Elementen. Die eingebauten Elemente sind:

| Element | Heute in |
|---|---|
| `Portrait` (Unit-Bild, Klassen-/Spec-Icon, Spiegeln) | `UpdatePortrait`, `GetUnitIcon`, `Mirror` |
| `Color` (Farbe des Rahmens) | `GetUnitColor` + `SetColor` in `Update` |
| `Frame` (Rahmen-Textur, Maske, Größe, Zoom) | `UpdateTextures`, `UpdateTexturesFiles`, `UpdateSize`, `UpdateZoom` |
| `Extra` (Rare/Elite/Boss) | `UpdateExtraTexture`, `GetExtraClassification` |
| `Desaturate` | `UpdateDesaturated` |
| `Ring` (Health/Cast-Ring) | `CreateRing`, `UpdateRing*` |
| `Cast` (Cast-Icon tauschen) | `CastStart`, `CastStop` |

Den genauen Schnitt legt der Builder fest, aber die Liste oben ist das, was Plugins sehen und ansprechen können.

**Element-Definition** (für eingebaute und Plugin-Elemente gleich):

```lua
API:RegisterElement("HealthText", {
	events = { "UNIT_HEALTH", "UNIT_MAXHEALTH" },
	Enable = function(element, portrait) return plugin.db.profile.enabled end,
	Disable = function(element, portrait) end,
	Update = function(element, portrait, event, unit) end,
})
```

- `Enable` wird bei jedem `PortraitSetup` aufgerufen und entscheidet pro Portrait. Liefert es `false`, wird das Element deaktiviert und seine Events werden abgemeldet.
- Events laufen über BPs bestehendes `OnEvent` und `RegisterEvents`. `UNIT_*` wird wie heute auf die Unit gefiltert. BP meldet ein Event nur einmal an, auch wenn mehrere Elemente es brauchen.

**Eingreifen in Elemente:**

```lua
API:HookElement("Color", {
	PreUpdate = function(element, portrait, unit) end,
	PostUpdate = function(element, portrait, unit, r, g, b) end,
	Override = function(element, portrait, event, unit) end,
})
```

- Ablauf je Update: alle `PreUpdate` in Registrierungsreihenfolge, dann `Override` falls vorhanden, sonst das eingebaute `Update`, dann alle `PostUpdate`.
- `PostUpdate` bekommt die Ergebnisse des Elements (zum Beispiel Farbe, Ring-Wert, gesetzte Textur). Welche Werte jedes eingebaute Element übergibt, steht in der Plugin-Doku.
- **Pro Element gibt es nur ein `Override`.** Ein zweites wird abgelehnt, mit einer Warnung, die beide Plugins nennt. *(Eigene Entscheidung: deterministisch statt „der Letzte gewinnt“.)*
- **Eigene Auslöser für eingebaute Elemente:** Heute laufen Farbe, Rahmen und Extra nur bei einer Zustandsänderung (GUID, Verfügbarkeit, Tod), Health treibt nur den Ring. Für eine Farbe nach HP oder „Portrait als Healthbar“ reicht das nicht. Deshalb kann `HookElement` zusätzlich `events = {...}` angeben: Bei diesen Events läuft genau dieses Element (Pre, Override oder Update, Post), ohne den zentralen Zustandscheck. Außerdem gibt es `API:UpdateElement(portrait, name)`, um ein einzelnes Element gezielt zu aktualisieren. Der zentrale Zustandscheck bleibt für BPs eigene Auslöser bestehen und entscheidet, welche Elemente laufen. Jedes Element muss also auch einzeln aufrufbar sein. *(Folgt aus der Entscheidung für Eingriffe, „B“.)*
- `HookElement` gilt für alle Portraits. Für einzelne Portraits kann ein Plugin in `PortraitSetup` nach `portrait.type` filtern.
- Ohne registrierte Hooks läuft der Update-Pfad ohne zusätzliche Aufrufe oder Tabellen.

**Fehler isolieren:** Funktionen von Plugins werden über `securecallfunction` aufgerufen, damit ein Fehler im Plugin zwar gemeldet wird (BugSack), BPs Update aber nicht abbricht. Der Builder prüft, ob es die Funktion in allen Flavors gibt. Sonst gibt es einen Fallback mit `xpcall` und `geterrorhandler()`. *(Eigene Entscheidung.)*

### Portrait-Objekt (stabile Felder)

Plugins dürfen lesen: `unit`, `type`, `key`, `db` (nur lesen), `isPlayer`, `isDead`, `isSecret`, `unitClass`, `parentFrame`, `parentAddon`. Für eigene Ebenen gibt es die Layer `texture`, `portrait`, `mask`, `bg`, `extra`, `ring` mit ihren heutigen Draw-Layern und Sublevels. Alle anderen Felder sind intern.

Plugin-Daten am Portrait liegen unter `portrait.plugins[pluginName]`, damit sie nicht mit BP-Feldern kollidieren.

### Helfer

`API:IsSecretValue(v)`, `API:SafeValue(v)`, `API:GetUnitColor(unit, ...)`, `API:UpdateElement(portrait, name)`, `API:Refresh()` (ruft `LoadPortraits`, inklusive Combat-Retry), `API:GetPortraits()` (Iterator über aktive Portraits).

### Doku und Beispiel

- `docs/plugin-api.md`: die Referenz für Plugin-Autoren (alles aus diesem Abschnitt, plus Hinweise zu Secret Values und Combat Lockdown).
- `examples/BP_ExamplePlugin/`: ein Plugin, das jede API einmal nutzt. Es liegt außerhalb von `Blinkiis_Portraits/` und landet deshalb nicht im Release-Zip. Es dient zugleich als manueller Test.

### Machbarkeitstest (Teil von „fertig“)

Das Beispiel-Plugin enthält zwei kleine Machbarkeitstests in **eigenem Code** (nichts aus Sashs Edit):

- **Portrait als Healthbar:** Das Unit-Bild füllt sich vertikal nach HP, das fehlende Stück wird abgedunkelt. Gebaut über `HookElement` am Element `Portrait` oder `Frame`, mit eigenen Events (`UNIT_HEALTH`).
- **Zweiter Ring:** Ein Plugin-Element per `RegisterElement`, das einen weiteren Radial-Ring (zum Beispiel Power) innerhalb des BP-Rings zeichnet.

Beide müssen auf Retail mit Secret Values laufen. Was dafür an der API fehlt (Masken, Draw-Layer, Felder), kommt **vor** dem Release in die API. Die API gilt erst als fertig, wenn beide Tests ohne Zugriff auf interne Felder auskommen.

### Releases

**Ein Release am Ende** (Blinkii, 21.11.2026): Die Phasen entstehen auf einem Branch. Die API wird erst veröffentlicht, wenn alle Phasen und die Machbarkeitstests stehen. Bis dahin darf sich der Vertrag noch ändern. Mit dem Release friert `API.version = 1` ein. Spätere Ergänzungen lassen die Version unverändert, Plugins prüfen dann per Existenz der Funktion.

### Phasen (auf dem Branch, jede ohne Verhaltensänderung)

1. API-Gerüst: `API`, Version, `NewPlugin`, Namespaces, Tab „Plugins“, Callbacks.
2. Frame-Provider-Registry, eingebaute Integrationen darauf umziehen.
3. Media-Registries.
4. Element-Modell: Gerüst, dann die Elemente einzeln umbauen (Vorschlag: Desaturate → Color → Extra → Portrait → Frame → Cast → Ring), danach `RegisterElement` und `HookElement` öffnen.
5. Beispiel-Plugin mit den Machbarkeitstests, API-Lücken schließen.
6. Doku fertigstellen, Eintrag im CHANGELOG, Release.

## Dem Builder überlassen

- Dateinamen und -aufteilung (zum Beispiel `api.lua` nach `core.lua`, `portraits/elements/*.lua`), wenn sie die Ladereihenfolge einhalten und in alle TOCs kommen.
- Der genaue Schnitt der eingebauten Elemente und welche Werte an `PostUpdate` gehen, im Rahmen der Tabelle oben.
- Interne Namen und Datenstrukturen der Registries.
- Prüfung pro Phase: luacheck und stylua, dazu manuelle Tests in mindestens Retail und einem Classic-Flavor mit ElvUI, SUF und Cell (Party).
