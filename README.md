# TFA Base Optimized

## What it is

A trimmed down and cleaned up version of TFA Base focused on stability and performance: fewer unnecessary hook calls, network operations, and allocations, cleaner module loading, and explicit early returns on heavy code paths.

## Key features

* Compact loader (`lua/tfa/framework/tfa_loader.lua`): single `loadFolder`, global cache, deterministic load order for modules/enums/external code.
* Ordered ConVars and commands (`lua/tfa/modules/tfa_commands.lua`): `EnsureReplConVar` and `CreateReplConVar` helpers eliminate dozens of repeated checks, default clip updates are moved into a dedicated callback.
* Optimized hooks (`lua/tfa/modules/tfa_hooks.lua`): cached `LocalPlayer`/active weapon, early returns if the weapon is not TFA, less work in `PlayerTick` and `PreRender`.
* Safer netcode (`lua/tfa/modules/tfa_netcode.lua`): localized `net.*`, player/weapon validity checks before doing anything.
* Scope rendering (`lua/tfa/modules/tfa_rendertarget.lua`): runs only for TFA weapons, reuses materials/RTs, correctly resets bones.
* Sound management (`lua/tfa/modules/tfa_functions.lua`): shared `addSound` helper, sound patching without duplication, localized references to `math/string/sound`.
* Attachments (`lua/tfa/modules/tfa_attachments.lua`): load order is "base -> everything else", cached inheritance, `ProtectedCall` around `TFAAttachmentsLoaded`.
* Particles and effects (`lua/tfa/modules/tfa_particles*.lua`): does not re-add already loaded PCFs, does not recompute offsets without a valid weapon, fewer unnecessary allocations.
* Backend (`lua/tfa/modules/tfa_backend.lua`): removed HTTP calls to Steam, no-op callbacks instead of network timeouts.
* M9K converter (`lua/tfa/modules/tfa_m9conversion.lua`): careful owner/data checks, cached math/string, sane defaults without hard assumptions.

## Behavior changes (good to know)

* Steam group check removed: functions in `tfa_backend.lua` return immediately. If you need the old group check, you will have to reintroduce it manually.
* Automatic resource precache removed: `tfa_precache.lua` keeps a directory cache and does not fire off heavy recursion. If needed, call `TFA.PrecacheDirectory` from your own code.
* Scope rendering now runs only for TFA weapons. If you piggybacked a custom SWEP on this logic, you will need to adapt it.

## What the optimization gives you

* Fewer global lookups and allocations thanks to localized APIs and shared helpers.
* Early exits on heavy paths (hooks, rendering, precache) so you do not burn frames for no reason.
* No more potential stalls from network or disk operations (Steam HTTP, massive startup precache).
* Cleaner module structure that is easier to maintain and extend.

## Quick integration guide

1. Copy the entire `tfa base optimized` folder as an addon (the folder name can be anything, for example `tfa_base_optimized`).
2. Make sure there is no other TFA Base version in addons. The loader will stop if it detects conflicting versions.
3. If your server needs specific ConVars, add them to your config - most of them are already created automatically.
4. For manual precache, when needed, use `TFA.PrecacheDirectory(path, type)` (`type`: `mat` / `mdl` / `snd` or empty for auto detection).

## Support and extensions

* If you want to bring back Steam group network checks or auto precache, add them in surgically so you do not lose performance in the rest of the code.
* When extending functionality, stick to the principles of this build: localize your APIs, validate early, and avoid blocking operations in hooks.
