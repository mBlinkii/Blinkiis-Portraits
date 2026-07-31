# Externals-Report: Blinkiis Portraits

- **Repo-Pfad:** `D:\Dev\Blinkiis Portraits`
- **Metadaten-Format:** `workflow`
- **Erstellt:** 30.07.2026 18:14
- **Ergebnis:** 12 erfolgreich, 0 fehlerhaft, 0 uebersprungen (von 12)

---

## Uebersicht

| Status | Zielpfad | Quelle | Ref | System |
|:---|:---|:---|:---|:---|
| OK | `Blinkiis_Portraits/libs/AceAddon-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceAddon-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceConfig-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceConsole-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceConsole-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceDB-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceDB-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceDBOptions-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceDBOptions-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceEvent-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceEvent-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceGUI-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/AceLocale-3.0` | https://repos.curseforge.com/wow/ace3/trunk/AceLocale-3.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/CallbackHandler-1.0` | https://repos.curseforge.com/wow/callbackhandler/trunk/CallbackHandler-1.0 | - | svn |
| OK | `Blinkiis_Portraits/libs/LibDeflate` | https://github.com/SafeteeWoW/LibDeflate.git | - | git |
| OK | `Blinkiis_Portraits/libs/LibSerialize` | https://github.com/rossnichols/LibSerialize.git | - | git |
| OK | `Blinkiis_Portraits/libs/LibStub` | https://repos.curseforge.com/wow/libstub/trunk | - | svn |

---

## Historie (letzte 5 Eintraege je Library)

### `Blinkiis_Portraits/libs/AceAddon-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceAddon-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1284` | 2022-09-25 | nevcairiel | Luacheck rules and conformance Also remove references to the old FindGlobals script, which were not maintained for ages, and the role has been taken by Luacheck now. |
| `r1238` | 2020-08-28 | nevcairiel | AceAddon-3.0: Blacklist more Blizzard addons from triggering Ace3 load events These addons can be loaded very early by UIParent, which causes issues with loading certain addons |
| `r1202` | 2019-05-15 | nevcairiel | Cleanup whitespace and add EditorConfig configuration Patch contributed by Stanzilla |
| `r1184` | 2018-07-21 | nevcairiel | Remove self-generating Dispatchers, and use xpcall, which now supports arguments |
| `r1084` | 2013-04-27 | nevcairiel | AceAddon-3.0: Don't call OnEnable if the addon/module was not initialized yet |

### `Blinkiis_Portraits/libs/AceConfig-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1386` | 2025-12-11 | nevcairiel | AceConfigDialog-3.0: Forward the "arg" option table member to widgets Widgets will receive the data through the SetCustomData function, if available, and can act on it as needed. This provides a clear lifecycle function before layout where the data is being made available. |
| `r1385` | 2025-12-06 | nevcairiel | AceConfig-3.0: Bump library versions for relative width support |
| `r1383` | 2025-12-06 | nevcairiel | AceConfig-3.0: Widget width can be defined to be relative to the container Syntax in the config table: width = "relative" relWidth = "0.25" This will result in a widget that takes up a quarter of the container's width. |
| `r1382` | 2025-12-05 | nevcairiel | AceConfigDialog-3.0: Preserve the original ID for BlizzOptions categories In Midnight, the ID must be numeric, so we can no longer use the name, and this may prevent taint spread by the ID field, since the automatically generated value is assigned securely. To open the settings panel through Settings.OpenToCategory, the ID needs to be passed, which is returned as the second value from :AddToBlizzOptions This change becomes effective when the new C_SettingsUtil API is added to the various clients, currently in 12.0 |
| `r1381` | 2025-12-05 | nevcairiel | AceConfigDialog-3.0: Remove InterfaceOptions_AddCategory support All supported WoW versions have moved on to the new Settings interface, so this was unused. |

### `Blinkiis_Portraits/libs/AceConsole-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceConsole-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1284` | 2022-09-25 | nevcairiel | Luacheck rules and conformance Also remove references to the old FindGlobals script, which were not maintained for ages, and the role has been taken by Luacheck now. |
| `r1202` | 2019-05-15 | nevcairiel | Cleanup whitespace and add EditorConfig configuration Patch contributed by Stanzilla |
| `r1143` | 2016-07-11 | nevcairiel | AceConsole-3.0: Fix a typo in the LuaDoc function signature |
| `r878` | 2009-11-02 | nevcairiel | More upvalue tweaks and cleanups |
| `r859` | 2009-10-05 | mikk | - Add :Printf() so you don't have to do Print(format()). Amagad saving several Lua instructions per addon :P - Optimize :Print() so it generates less garbage strings when given multiple arguments. |

### `Blinkiis_Portraits/libs/AceDB-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceDB-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1364` | 2025-07-05 | nevcairiel | AceDB-3.0: Avoid hitting the metatable when looking up the keys |
| `r1363` | 2025-07-05 | nevcairiel | AceDB-3.0: Aggressively cleanout empty profiles tables inside namespace on logout This should help cleanup unloaded empty namespaces |
| `r1361` | 2025-05-17 | nevcairiel | AceDB-3.0: Cleanup empty namespace tables Some addons use a large amount of namespaces which rarely get used, and empty tables can clutter the SV. Cleaning up empty tables is consistent with the other cleanup tasks done at logout, as they'll be re-created if needed. |
| `r1353` | 2024-08-27 | nevcairiel | AceDB-3.0: Handle unloaded namespaces in Reset/Copy/Delete functions When applying profile changes to namespaces, we should also handle namespaces that are not currently loaded. These may be from optional Load-on-Demand parts that are not currently loaded, but the expectation is that the database behaves consistent no matter what is currently active. |
| `r1328` | 2024-03-20 | nevcairiel | AceDB-3.0: Sync type checks for New and ResetDB defaultProfile |

### `Blinkiis_Portraits/libs/AceDBOptions-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceDBOptions-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1304` | 2023-05-19 | nevcairiel | AceDBOptions-3.0: Minor locale fixes for russian |
| `r1303` | 2023-05-16 | nevcairiel | AceDBOptions-3.0: Update locale strings Fixes WoWAce #629 |
| `r1284` | 2022-09-25 | nevcairiel | Luacheck rules and conformance Also remove references to the old FindGlobals script, which were not maintained for ages, and the role has been taken by Luacheck now. |
| `r1202` | 2019-05-15 | nevcairiel | Cleanup whitespace and add EditorConfig configuration Patch contributed by Stanzilla |
| `r1193` | 2018-08-02 | funkydude | Remove some local references we don't use. |

### `Blinkiis_Portraits/libs/AceEvent-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceEvent-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1202` | 2019-05-15 | nevcairiel | Cleanup whitespace and add EditorConfig configuration Patch contributed by Stanzilla |
| `r1161` | 2017-08-12 | funkydude | Bump minor versions where required (As affected by PlaySound changes, or by loading order problem) |
| `r1160` | 2017-08-12 | funkydude | If we are loading a library that depends on a separate library, we need to verify that separate library exists prior to telling LibStub to create our library. This resolves addons with broken library setups affecting addons with working library setups. |
| `r975` | 2010-10-23 | nevcairiel | AceEvent-3.0: Fix documentation |
| `r877` | 2009-11-02 | nevcairiel | Cleaned upvalues and added comments for Mikk's FindGlobals script |

### `Blinkiis_Portraits/libs/AceGUI-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1396` | 2026-06-20 | funkehdude | AceGUI-3.0/widgets/AceGUIWidget-CheckBox: Fix setting desaturation on WoW 12.1 |
| `r1391` | 2026-03-06 | funkehdude | AceGUI-3.0/widgets/AceGUIWidget-Slider: Workaround font loading issue sometimes making freshly created editboxes blank until the text is changed. |
| `r1384` | 2025-12-06 | nevcairiel | AceGUI-3.0: Keybinding: Add gamepad support Gamepad bindings are completely in line with the rest of the keybinding system in WoW, so all that's really necessary to make them work in AceGUI is to add a handler to catch bindings. |
| `r1379` | 2025-11-27 | nevcairiel | AceGUI-3.0: TreeGroup: Pass an explicit alpha value to SetText Fixes CF-#685 |
| `r1369` | 2025-10-02 | nevcairiel | AceGUI-3.0: EditBox: Fix InsertLink hook for 12.0 |

### `Blinkiis_Portraits/libs/AceLocale-3.0`

- Quelle: https://repos.curseforge.com/wow/ace3/trunk/AceLocale-3.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r1284` | 2022-09-25 | nevcairiel | Luacheck rules and conformance Also remove references to the old FindGlobals script, which were not maintained for ages, and the role has been taken by Luacheck now. |
| `r1035` | 2011-07-09 | kaelten | AceLocale: fixed bug when trying to edit a silent Locale from separate files. AceDB: Added locale and factionrealmregion profile keys |
| `r1005` | 2011-01-29 | mikk | AceLocale-3.0: Do not send a 2nd parameter to errorhandler. (Causes problem for Swatter.. heh why?) |
| `r1004` | 2011-01-26 | mikk | AceLocale-3.0: Aaaaand remember to bump the minor. ~slap Mikk |
| `r1003` | 2011-01-26 | mikk | AceLocale-3.0: - Change the error() on trying to register a silent locale in the wrong way to a geterrorhandler() warning. - Add tests for above. |

### `Blinkiis_Portraits/libs/CallbackHandler-1.0`

- Quelle: https://repos.curseforge.com/wow/callbackhandler/trunk/CallbackHandler-1.0
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r26` | 2022-12-12 | nevcairiel | Use securecallfunction instead of xpcall This allows error handlers to properly use debuglocals() when handling any potential errors in the callback. Change contributed by Meorawr |
| `r25` | 2022-12-12 | nevcairiel | Sync up style changes with Ace3 |
| `r22` | 2018-07-21 | nevcairiel | Replace generated Dispatcher with xpcall, which now supports arguments |
| `r18` | 2014-10-16 | mikk | TOC 60000 Tear out some beta-times checks that could have been removed many years ago |
| `r14` | 2010-08-09 | mikk | Ticket 5: Allow 'self or addonId' to be a thread (coroutine) |

### `Blinkiis_Portraits/libs/LibDeflate`

- Quelle: https://github.com/SafeteeWoW/LibDeflate.git
- System: git

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `afc3b78` | 2021-05-05 | SafeteeWoW | [dev] Exclude dev_docs in .pkgmeta |
| `9500e14` | 2021-05-05 | SafeteeWoW | [doc] Add serveral doc for develop |
| `c47202a` | 2021-05-05 | SafeteeWoW | [dev] Update .clang-format with 120 column width |
| `00fee39` | 2021-05-05 | SafeteeWoW | [dev] Reformat C code using 120 column width |
| `c103ad9` | 2021-05-05 | SafeteeWoW | [doc] Update README related to CI |

### `Blinkiis_Portraits/libs/LibSerialize`

- Quelle: https://github.com/rossnichols/LibSerialize.git
- System: git

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `e89d505` | 2026-07-16 | Ross Nichols | Add test coverage for encoding paths, references, and malformed input (#16) |
| `40d96aa` | 2026-07-15 | Ross Nichols | Bump minor version (#15) |
| `2a12745` | 2026-07-15 | Ross Nichols | Fix (de)serialization edge cases: large ints, subnormals, negative zero, stable sort (#14) |
| `53b60a6` | 2024-05-20 | Ross Nichols | Update .pkgmeta |
| `7916fe1` | 2024-05-20 | Ross Nichols | Add test case for simultaneous async operations |

### `Blinkiis_Portraits/libs/LibStub`

- Quelle: https://repos.curseforge.com/wow/libstub/trunk
- System: svn

| Revision | Datum | Autor | Nachricht |
|:---|:---|:---|:---|
| `r109` | 2021-05-04 | kaelten | update toc version |
| `r108` | 2018-08-12 | kaelten | Updating WoW Toc Version |
| `r107` | 2017-06-17 | kaelten | update toc version for 7.2.5 |
| `r105` | 2016-08-18 | kaelten | Updating ToC for Legion. |
| `r103` | 2014-10-16 | mikk | TOC 60000 |

