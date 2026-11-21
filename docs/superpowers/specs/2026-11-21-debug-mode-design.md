# Debug-Modus – Design (kurz)

Stand: 21.11.2026 · freigegeben von Blinkii im Chat

**Warum:** Fehler sollen sich eindeutig BP zuordnen lassen, ohne dass fremde Addons oder Plugins mitspielen.

**Was:** `/bp debugmode` schaltet für den aktuellen Charakter alle Addons ab außer:
- Blinkiis Portraits selbst
- den unterstützten Addons, die gerade aktiv sind: alle Frame-Provider aus der Registry und JiberishIcons. Abgeschaltete werden nicht eingeschaltet.
- BugSack und !BugGrabber
- allen Abhängigkeiten dieser Addons (rekursiv)
- Load-on-Demand-Modulen, die nur von behaltenen Addons abhängen (z. B. `ElvUI_Options`), außer sie hängen von Blinkiis Portraits ab (das sind Plugins)

Vorher fragt ein Popup nach Bestätigung, danach lädt das UI neu. `/bp debugmode off` schaltet genau die Addons wieder ein, die BP abgeschaltet hat, und lädt neu. Solange der Modus aktiv ist, erinnert beim Einloggen eine Chatzeile daran.

**Nicht-Ziele:** keine Plugin-Verwaltung, keine Wirkung auf andere Charaktere.

**Ansätze:** Es gab nur einen sinnvollen Weg: WoWs Addon-API (`C_AddOns`) mit einer gespeicherten Liste der abgeschalteten Addons. Ein eigenes Lade-Verbot für Plugins innerhalb von BP wäre unvollständig gewesen, weil es fremde Addons nicht erfasst.

**Umsetzung (eigene Entscheidungen):**
- Die Auswahl-Logik steckt in `debugmode.lua` und ist offline testbar.
- Die abgeschalteten Namen liegen in `db.char.debugMode` (AceDB, pro Charakter).
- Abgeschaltet und eingeschaltet wird mit dem Charakternamen als Ziel.
