# Statusfenster – Design und Plan (kurz)

Freigegeben von Blinkii im Chat, 21.11.2026.

**Was:** `/bp report` wird `/bp status`. Das Fenster ist klein und zeigt nur, was beim Debuggen hilft, mit einem Plugin-Kasten daneben (Idee von ElvUIs Statusfenster, kein Code daraus).

**Inhalt:**
- AddOn Info: Version, Profil, Unitframe-Addons mit Version, Other AddOns (yes/no), Debug-Modus
- WoW Info: Version und Build, Spielmodus, Sprache
- Portraits: eine Zeile pro Einheit (ok grün, missing rot, off grau, Gruppen als n/5)
- Changed Settings: nur globale Einstellungen, die vom Standard abweichen
- Plugins: Name und Version pro Plugin, Frame-Provider und Styles von Plugins
- Kopieren-Knopf bleibt

**Weg fällt:** Target Info, Interface-Nummer, Zone und Gruppe, Kampfstatus, Boss-ID-Cache, Import/Export-API und Einstellungen, die auf Standard stehen.

**Tasks:**
1. `status.lua` ersetzt `report.lua`. Offline getestet werden `GetChangedSettings()`, `GetPortraitSummary()`, `GetPluginStatusRows()` und `GetStatusText()`.
2. Fenster mit Hauptkasten und Plugin-Kasten. `/bp status`, Knopf in den Optionen, Strings.
