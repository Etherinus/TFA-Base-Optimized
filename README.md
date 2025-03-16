## TFA Base Optimized

A lightweight and optimized version of TFA Base, designed for those who want to keep core weapon functionality without extra or unnecessary files.

### Key Features

- **Minimal Set of Code**: Only the essential scripts for running TFA Base have been retained.
- **Optimizations**: Duplicate code removed, improved readability, reduced potential conflicts with other addons.
- **Lightweight Integration**: Simplified structure, making it easier to maintain and adapt to your own needs.
- **Compatibility**: Core TFA mechanics (reload, hitmarkers, scopes, etc.) remain unchanged.

### Which Files and Folders Were Optimized?

- **Main Scripts**:
  - `base.lua`, `tfa_loader.lua`, `status.lua` and others that handle weapon logic and statuses.
  - Sound and particle handling files (`tfa_soundscripts.lua`, `tfa_particles.lua`, `tfa_particles_lua.lua`), plus precaching scripts (`tfa_precache.lua`).
  - Auxiliary scripts for visual effects control (`tfa_rendercode.lua`, `tfa_rendertarget.lua`), HUD logic, and settings (`tfa_vgui.lua`, `tfa_hooks.lua`).
  - Attachment inheritance and loading system (`tfa_attachments.lua`, `tfa_attachments_hardcode.lua`).

- **Folders**:
  - `lua/tfa` — the main TFA logic, containing essential weapon modules.
  - `lua/autorun` — auto-run scripts, cleaned up and stripped of unnecessary checks.
  - `materials/` — includes scope textures and other materials; any unused items have been removed.
  - `sound/` — includes TFA sound assets; structure has been reorganized and scripts updated.

### Installation

1. Download or clone this repository into your Garry’s Mod `addons` folder (e.g. `addons/tfa_base`).
2. Restart your server or client to apply changes.

### Additional Notes

- This code is for those who want minimal overhead and better performance.
- You can remove more files if certain features (e.g., advanced rendering or M9K conversions) are not needed.
- Generally compatible with other TFA expansions unless they require files you’ve removed.
