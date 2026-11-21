# Blinkiis Portraits plugin API

Blinkiis Portraits (BP) attaches portraits to the frames of other unit frame addons. Plugins are separate addons that extend it: they can bring their own frames, styles and icon sets, add their own parts to a portrait and change how BP draws its own parts.

Everything documented here lives in `BLINKIISPORTRAITS.API` and stays stable within an API version. Everything else on `BLINKIISPORTRAITS` is internal and can change in any release.

A complete example that uses every function is in [`examples/BP_ExamplePlugin`](../examples/BP_ExamplePlugin). It also has a self test, `/bpex test`.

## Getting started

```toc
## Dependencies: Blinkiis_Portraits
```

```lua
local API = BLINKIISPORTRAITS.API

local plugin = API:NewPlugin("MyPlugin", {
	apiVersion = 1,
	defaults = { profile = { enabled = true } },
	options = function()
		return { type = "group", name = "My Plugin", args = { ... } }
	end,
})
```

- `API.version` is the current API version (`1`). Additions keep the version; breaking changes raise it. To use a function added later, check it exists: `if API.RegisterSomething then`.
- `NewPlugin(name, opts)` returns the plugin handle, or `nil, reason` when the name is taken, `apiVersion` does not match, or BP is not initialized yet. Register from your addon's main chunk or later.
- `plugin.db` is an AceDB namespace: it follows the BP profile and is copied with it. `plugin.name` is the name you passed.
- `opts.options` builds an AceConfig group that appears as a tab under **Plugins** in `/bp` and in the ElvUI options. The EllesmereUI options take their snapshot before plugins load, so plugin tabs do not appear there; `/bp` always shows them.
- `API:GetPlugin(name)` and `API:IteratePlugins()` return registered plugins.

## Profiles

Profile export, import and copy carry the settings of plugins that are enabled and loaded. On import, settings of plugins that are not loaded are skipped and BP names them in the chat. A plugin missing from an imported profile starts it from its defaults. Old export strings import as before.

## Callbacks

```lua
API.RegisterCallback(self, "PortraitSetup", function(event, portrait) end)
API.UnregisterCallback(self, "PortraitSetup")
```

| Event | Arguments | When |
|---|---|---|
| `PortraitCreated` | `portrait` | a portrait frame was created |
| `PortraitSetup` | `portrait` | after every setup (new parent, profile, options) |
| `PortraitUnitChanged` | `portrait, unit` | the resolved unit changed |
| `PortraitUpdated` | `portrait, event` | after an update that changed the unit state |
| `PortraitRemoved` | `portrait` | the portrait was removed |
| `PortraitsLoaded` | | all portraits were (re)loaded |
| `ProfileChanged` | | the profile was changed, copied or reset |

A callback that errors is reported and does not stop the others. One target can hold one handler per event.

## Frame providers

Tell BP which of your frames belongs to a unit, and it attaches its portraits to them.

```lua
API:RegisterFrameProvider("myuf", {
	label = "My Unit Frames",
	addons = { "MyUnitFrames" },
	units = {
		player = "MyUF_Player",
		party = function(index) return _G["MyUF_Party" .. index] end,
	},
	getUnit = function(frame) return frame.myUnit end,
	unitRestriction = nil,
	priority = nil,
})
```

- `addons`: folder names; the provider is used only while one of them is loaded.
- `units[unit]`: a global frame name, a dot path (`"MyUF.frames.player"`), or a function returning the frame. For `party`, `boss` and `arena` a string is the base name the index is appended to, and a function receives the index.
- `getUnit` (optional): returns the unit of a frame when it is not in `frame.unit`, `frame.__unit`, `frame._unit` or the `unit` attribute.
- `unitRestriction` (optional): the provider serves only this unit.
- `priority` (optional): lower wins in automatic selection. Built-in providers use 10 to 120, plugin providers default to 1000 and up in registration order.
- The provider appears in every unit's frame selection. A saved selection whose provider is gone behaves like "auto".
- Returns `false` for a taken id or missing `addons`/`units`.

## Styles and icon sets

```lua
API:RegisterStyle("mystyle", { name = "My Style", texture = path, mask = path, extra = path, mask_mirror = path, extra_mirror = path })
API:RegisterClassIconSet("myicons", { name = "My Icons", texture = path, texCoords = { WARRIOR = { l, r, t, b }, ... } })
API:RegisterSpecIconSet("myspecs", { name = "My Specs", texture = path, texCoords = { [specID] = { ... } } })
```

- They appear in the style, class icon and spec icon selections. `texCoords` take 4 or 8 values.
- Spec icon sets only work where BP supports spec icons (Retail); elsewhere the call returns `false`.
- A taken id or a missing `name`, `texture` (styles: `mask`) returns `false`.
- Registering after the portraits loaded reloads them once. A selected style or set that disappears (plugin disabled) falls back to the default.

## Elements

A portrait is built from elements. Each element has an `Update` that BP runs; plugins can hook it or add their own elements.

### Built-in elements and their results

| Element | Draws | Results (passed to `PostUpdate`) |
|---|---|---|
| `Portrait` | unit image, class or spec icon, mirroring | `texture` (nil when the game painted the unit model), `texCoords` |
| `Color` | frame color | `color` (`r, g, b, a`, may be secret) |
| `Frame` | frame texture, mask, zoom | `texturePath`, `maskPath` |
| `Extra` | rare, elite and boss texture | `classification` or nil |
| `Desaturate` | grey portrait when dead or forced | `isDesaturated` |
| `Ring` | health or cast ring | `value`, `maxValue` (health, may be secret), `mode` |
| `Cast` | cast icon | `castIcon` or nil when the cast ends |

The first result of every element is kept as `portrait.elements[name].result`, so a later element sees an overridden value. `Extra` takes its color from `Color` this way.

### Hooking an element

```lua
API:HookElement(plugin, "Color", {
	PreUpdate = function(element, portrait, unit) end,
	Override = function(element, portrait, event, unit) return color end,
	PostUpdate = function(element, portrait, unit, ...) end,
	events = { "UNIT_HEALTH" },
})
```

- Order: every `PreUpdate`, then `Override` or the built-in update, then every `PostUpdate` with the results.
- Only one plugin can override an element. A second override is refused, and the warning names both plugins.
- `events` run this element on these events too, outside BP's own triggers. This re-runs the whole built-in update each time: hooking `Portrait` with `UNIT_HEALTH` repaints the unit image on every health tick. For your own frequent updates, register your own element instead.
- `API:UpdateElement(portrait, name)` runs one element right now.
- A hook that errors is reported and does not stop BP or the other hooks.

### Own elements

```lua
API:RegisterElement(plugin, "MyText", {
	events = { "UNIT_HEALTH" },
	Enable = function(element, portrait) return plugin.db.profile.enabled end,
	Disable = function(element, portrait) end,
	Update = function(element, portrait, event, unit) end,
})
```

- `Enable` runs on every portrait setup and decides per portrait; `element.enabled` holds the answer. When it turns false, `Disable` runs once and the element's events stop.
- Built-in and taken names are refused. `RegisterElement` and `HookElement` need the handle from `NewPlugin`.
- `element` is a per-portrait table for your own state, also reachable as `portrait.elements[name]`.

## The portrait

Stable fields to read: `unit`, `type`, `key`, `db` (read only), `isPlayer`, `isDead`, `isSecret`, `unitClass`, `parentFrame`, `parentAddon`, `elements`.

Layers to draw against, with their draw layers:

| Field | Layer |
|---|---|
| `bg` | BACKGROUND 1 |
| `portrait` | ARTWORK 2 (unit image) |
| `texture` | ARTWORK 4 (frame shape) |
| `ring` | ARTWORK 6 (only with a ring mode) |
| `extra` | OVERLAY 7, or 1 when not drawn on top |
| `mask` | mask of the unit image |

Keep your data in `portrait.plugins[yourPluginName]`.

## Helpers

- `API:IsSecretValue(value)`, `API:SafeValue(value)` (nil for a secret value)
- `API:GetUnitColor(unit, isDead, isPlayer, class, isSecret)`
- `API:GetPortraits()`: iterates `key, portrait`
- `API:Refresh()`: reloads all portraits (waits for the end of combat)

## Secret values and combat

- On Retail, health, power, class and identity of some units are secret. BP passes them on unchanged. Never compare them, calculate with them or use them as table keys; hand them to StatusBars or use the game's secret-aware APIs.
- Creating frames, anchoring them and setting secure attributes is blocked in combat. Do that in `PortraitSetup`, which BP only runs out of combat.
