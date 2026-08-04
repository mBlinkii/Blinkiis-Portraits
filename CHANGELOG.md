# Changelog - Blinkii's Portraits

## [ver. 1.57] - 04.08.2026
### ✨ NEW
- NEW - [ElvUI]: The options are shown inside the ElvUI options menu again and the addon is listed in the ElvUI plugin list.
- NEW - [Options]: Add a toggle to disable the ElvUI options integration.
- NEW - [Options]: Every portrait now has a copy dropdown to take over the settings of another portrait, except its enable state and parent frame.
- NEW - [ElvUI]: The addon logo is shown above the options and the addon icon on the button in the ElvUI menu.

## [ver. 1.56] - 30.07.2026
### 🔧 UPDATE
- UPDATE - [System]: Ace3, LibSerialize and LibDeflate are now fetched fresh for every release, so each build ships the current library versions.
- UPDATE - [System]: Removed the unused Ace3 modules AceTimer, AceBucket, AceHook, AceComm, AceTab and AceSerializer from the package.

## [ver. 1.55] - 25.07.2026
### 🐛 FIX
- FIX - [Party]: Party portraits stayed black until a reload because UNIT_PORTRAIT_UPDATE and PORTRAITS_UPDATED did not refresh the texture.
- FIX - [Portraits]: Portraits stayed empty when the parent unit frame exposed no unit.
- FIX - [Unitframes]: A loaded unit frame addon without frames for a unit no longer blocks all lower priority addons.
- FIX - [Cast-Icons]: The cast icon was restored once per stop and interrupt event instead of once per cast.
- FIX - [System]: OptionalDeps listed Unhalted Unit Frames under the wrong addon name and was missing NDui, BetterBlizzFrames and EllesmereUI.
### 🔧 UPDATE
- UPDATE - [Portraits]: UNIT_TARGET is now registered unit filtered instead of globally.
- UPDATE - [Portraits]: PORTRAITS_UPDATED no longer updates portraits whose unit is not present.
- UPDATE - [Party]: The separate party player frame is now resolved from the unit frame table instead of a hardcoded name.
- UPDATE - [Party]: Party portraits are recreated on roster changes, for unit frames that create their buttons on demand.
### ✨ NEW
- NEW - [UUF]: Add support for Unhalted Unit Frames party frames.

## [ver. 1.54] - 12.07.2026
### 🔧 UPDATE
- UPDATE - [System]: Automated release process for GitHub, CurseForge and Wago.

## [ver. 1.53] - 12.07.2026
### 🐛 FIX
- FIX - [Cell]: Removed the non-functional Cell arena frame reference.
### 🔧 UPDATE
- UPDATE - [Portraits]: Refactored unit portrait setup into shared functions to reduce code duplication.
- UPDATE - [Portraits]: Optimized event registration, UNIT_* events now use RegisterUnitEvent where possible.

## [ver. 1.52] - 22.06.2026
### 🐛 FIX
- FIX - [Options]: Fixed a nil error in the popup dialogs.
### 🔧 UPDATE
- UPDATE - [EllesmereUI]: Add support for EllesmereUI party frames.
- UPDATE - [System]: Update game version.
### ✨ NEW
- NEW - [Stuf]: Add support for Stuf.
- NEW - [Options]: Add a disable button for clickable portraits.

## [ver. 1.51] - 21.04.2026
### 🐛 FIX
- FIX - [Portraits]: The player portrait was not showing on first login.
- FIX - [Portraits]: Target change events now return the correct event.

## [ver. 1.50] - 20.04.2026
### 🐛 FIX
- FIX - [SUF]: Fixed a unit frame bug with SUF that returned a wrong condition.
- FIX - [Profiles]: Fixed a bug in the profile structure.
- FIX - [Boss]: Fixed boss portrait initialization.
- FIX - [Portraits]: Corrected the state change detection in the portrait update.
- FIX - [Portraits]: Portraits now update correctly on target and focus change.
### 🔧 UPDATE
- UPDATE - [Class-Icons]: Add an option to ignore class icons on specific portraits.
### ✨ NEW
- NEW - [EllesmereUI]: Add support for EllesmereUI.
- NEW - [BBF]: Add support for BetterBlizzFrames.

## [ver. 1.49] - 12.04.2026
### 🐛 FIX
- FIX - [EQOL]: Fixed a missing unit in combination with EnhanceQoL.
### 🔧 UPDATE
- UPDATE - [EQOL]: Add support for EnhanceQoL party frames.

## [ver. 1.48] - 27.02.2026
### 🐛 FIX
- FIX - [Portraits]: Fixed a desaturate bug with target portraits.

## [ver. 1.47] - 21.02.2026
### 🔧 UPDATE
- UPDATE - [Portraits]: Removed the health checks.
- UPDATE - [System]: Update game version.
### ✨ NEW
- NEW - [EQOL]: Add support for EnhanceQoL unit frames.
- NEW - [Textures]: Add the missing mMT 4.0 textures.

## [ver. 1.46] - 05.02.2026
### 🐛 FIX
- FIX - [Portraits]: Fixed the portraits for unit frames.
- FIX - [Portraits]: Fixed the handling of secure values.

## [ver. 1.44] - 04.11.2025
### 🐛 FIX
- FIX - [Portraits]: Prevent initialization during combat.
- FIX - [Boss]: Fixed the world boss indicator.
### 🔧 UPDATE
- UPDATE - [Boss]: Boss IDs are now cached.

## [ver. 1.43] - 25.08.2025
### 🐛 FIX
- FIX - [Cell]: Player and target portraits were not showing when Cell is loaded with the auto setup.
- FIX - [Portraits]: The death status did not update correctly.
### 🔧 UPDATE
- UPDATE - [Vehicle]: Optimized the portrait change when entering or leaving a vehicle.
- UPDATE - [Cell]: Split the requirements for Cell and Cell Unit Frames.

## [ver. 1.42] - 09.08.2025
### 🐛 FIX
- FIX - [Cast-Icons]: Cast icons were not working.
### 🔧 UPDATE
- UPDATE - [System]: Code cleanup.
- UPDATE - [Cell]: Split the requirements for Cell and Cell Unit Frames.

## [ver. 1.41] - 06.08.2025
### 🔧 UPDATE
- UPDATE - [System]: Update the retail game version.
### ✨ NEW
- NEW - [Textures]: Add the extra texture Elite.

## [ver. 1.40] - 28.07.2025
### 🐛 FIX
- FIX - [Portraits]: The portraits sometimes did not update correctly.
### ✨ NEW
- NEW - [Textures]: Add the portrait texture Moon.
- NEW - [Textures]: Add the extra textures Snake, Dragon, Dogs, Plants and Comet.

## [ver. 1.39] - 18.07.2025
### 🐛 FIX
- FIX - [SUF]: Prevent nil errors in combination with SUF.
- FIX - [SUF]: Fixed the portrait update events for SUF.
### ✨ NEW
- NEW - [Textures]: Add the portrait texture Oval.
- NEW - [Textures]: Add the portrait texture Oval Horizontal.
- NEW - [Textures]: Add the portrait texture Rectangular.

## [ver. 1.38] - 17.07.2025
### 🐛 FIX
- FIX - [Vehicle]: Possible fix for the bug with the player and pet portrait in a vehicle.
- FIX - [Party]: Fixed wrong party portraits.
### 🔧 UPDATE
- UPDATE - [Portraits]: Reworked the portrait update events.
- UPDATE - [System]: Update the logo and the icon.

## [ver. 1.37] - 03.07.2025
### 🐛 FIX
- FIX - [Class-Icons]: Fixed a bug with enabled class icons on target units.
### ✨ NEW
- NEW - [Localization]: Add localization for ruRU, big thanks to ZamestoTV.

## [ver. 1.36] - 02.07.2025
### 🔧 UPDATE
- UPDATE - [NDui]: Improved the loading behaviour for NDui.
- UPDATE - [System]: Update for Mists of Pandaria Classic.

## [ver. 1.35] - 27.06.2025
### 🔧 UPDATE
- UPDATE - [Party]: Optimized the party portraits update function.
### ✨ NEW
- NEW - [NDui]: Add support for NDui.
- NEW - [Localization]: Add localization for zhCN and zhTW, big thanks to huchang47.
- NEW - [Localization]: Add localization for deDE.

## [ver. 1.34] - 18.06.2025
### 🔧 UPDATE
- UPDATE - [System]: Update the game version.
- UPDATE - [Colors]: Optimized the reaction check.

## [ver. 1.33] - 10.05.2025
### 🐛 FIX
- FIX - [Boss]: Prevent players from being marked as a boss.

## [ver. 1.32] - 10.05.2025
### 🐛 FIX
- FIX - [Textures]: The extra textures E and L were missing.
- FIX - [Portraits]: Fixed a portrait bug in delves.
### ✨ NEW
- NEW - [Textures]: Add the portrait texture Diagonal Mirror.
- NEW - [UUF]: Add support for Unhalted Unit Frames, thanks to Cbogolin.

## [ver. 1.31] - 02.05.2025
### 🐛 FIX
- FIX - [Portraits]: Reset the portrait offset and zoom to prevent black portraits.

## [ver. 1.30] - 01.05.2025
### 🐛 FIX
- FIX - [Cell]: Portraits did not work correctly with Cell party and boss frames.
- FIX - [Options]: Force a UI reload after the parent frame setting has been changed.
- FIX - [SUF]: Higher update delay to prevent bugs with SUF.
### 🔧 UPDATE
- UPDATE - [ElvUI]: Removed the integration into the ElvUI options menu.
- UPDATE - [Portraits]: Reduced the clickable area of the portraits.
### ✨ NEW
- NEW - [Options]: Add an About page to the options.
- NEW - [Profiles]: Add a profile export and import function.

## [ver. 1.29] - 25.04.2025
### 🔧 UPDATE
- UPDATE - [System]: Update the game version.

## [ver. 1.28] - 16.04.2025
### 🐛 FIX
- FIX - [ElvUI]: Fixed a bug with the ElvUI options search function.

## [ver. 1.27] - 23.03.2025
### 🐛 FIX
- FIX - [System]: Removed leftover development prints.

## [ver. 1.26] - 23.03.2025
### 🐛 FIX
- FIX - [SUF]: Fixed an update bug with SUF and party frames.
### ✨ NEW
- NEW - [Options]: The parent frame can now be selected per dropdown, for setups with multiple unit frame addons like Cell and SUF.

## [ver. 1.25] - 21.02.2025
### 🐛 FIX
- FIX - [Vehicle]: Fixed the player and pet portrait while the player is in a vehicle.
### 🔧 UPDATE
- UPDATE - [System]: Update the classic game version.
### ✨ NEW
- NEW - [Options]: Add a force desaturate option for the portraits.

## [ver. 1.24] - 04.02.2025
### 🐛 FIX
- FIX - [Class-Icons]: Fixed the portraits for non-players when class icons are enabled.
- FIX - [Class-Icons]: Fixed the missing disable function for class icons.
### 🔧 UPDATE
- UPDATE - [System]: Update the classic game version.
### ✨ NEW
- NEW - [Textures]: Add a force extra texture option to the target, target of target, focus, pet and party frames.

## [ver. 1.23] - 25.01.2025
### ✨ NEW
- NEW - [Class-Icons]: You can now add your own custom class icons to the portraits.

## [ver. 1.22] - 12.01.2025
### 🐛 FIX
- FIX - [SUF]: Portraits did not work with the SUF arena and boss frames.
- FIX - [Portraits]: Fixed a nil error when the parent frame does not exist.
### 🔧 UPDATE
- UPDATE - [Portraits]: Portraits now take care of the SUF and ElvUI test and demo mode.

## [ver. 1.21] - 03.01.2025
### 🐛 FIX
- FIX - [Textures]: The rare and elite texture did not work correctly.
- FIX - [Class-Icons]: Switching back from class icons to the portrait could break the portrait.
- FIX - [Options]: Fixed the color reset buttons in the settings menu.
### 🔧 UPDATE
- UPDATE - [Textures]: Extra on Top is now enabled by default, which shows the extra texture on top of the portraits.
- UPDATE - [Textures]: The default extra textures are now Blizzard Neutral and Blizzard Boss Neutral.
### ✨ NEW
- NEW - [Textures]: Add two variants of the Blizzard extra texture, Neutral and Boss Neutral.

## [ver. 1.2] - 01.01.2025
### 🔧 UPDATE
- UPDATE - [Portraits]: Optimized the portrait update code.
### ✨ NEW
- NEW - [Class-Icons]: Add class icon support.

## [ver. 1.1] - 29.12.2024
### 🔧 UPDATE
- UPDATE - [Textures]: Add the Blizzard rare, elite and boss textures.
### ✨ NEW
- NEW - [Cell]: Add support for Cell and Cell Unit Frames, both are required.

## [ver. 1.0] - 27.12.2024
### 🐛 FIX
- FIX - [System]: Removed all debug prints.
### 🔧 UPDATE
- UPDATE - [System]: Code optimizations.
### ✨ NEW
- NEW - [PitBull4]: Add support for PitBull 4.
- NEW - [System]: Add support for Classic and Cataclysm.
