# libs

This folder holds the embedded third-party libraries that `embeds.xml` loads.
They are **not** checked into the repo; the release workflow fetches them fresh
on every tag. Add them locally before running the addon from a fresh clone.

## Required

- **Ace3** (used modules: AceAddon-3.0, AceEvent-3.0, AceConsole-3.0,
  AceLocale-3.0, AceDB-3.0, AceDBOptions-3.0, AceGUI-3.0, AceConfig-3.0,
  plus LibStub and CallbackHandler-1.0) — https://www.curseforge.com/wow/addons/ace3

Profile import and export run on the `C_EncodingUtil` game API, no serialization
or compression library is needed.

## How to populate

Download each library and extract it so the folder layout matches the paths in
`embeds.xml` (e.g. `libs/AceAddon-3.0/AceAddon-3.0.xml`), or run the same
commands the release workflow uses:

```sh
svn export --force https://repos.curseforge.com/wow/libstub/trunk libs/LibStub
svn export --force https://repos.curseforge.com/wow/callbackhandler/trunk/CallbackHandler-1.0 libs/CallbackHandler-1.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceAddon-3.0 libs/AceAddon-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceEvent-3.0 libs/AceEvent-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceConsole-3.0 libs/AceConsole-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceLocale-3.0 libs/AceLocale-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceDB-3.0 libs/AceDB-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceDBOptions-3.0 libs/AceDBOptions-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0 libs/AceGUI-3.0
svn export --force https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0 libs/AceConfig-3.0
```
