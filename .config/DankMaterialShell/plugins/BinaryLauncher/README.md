# Binary Launcher — DMS Launcher Plugin

A [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) launcher
plugin that scans one or more directories you configure for **executable files**
and lets you launch them from the DMS launcher.

Useful for `~/bin`, `~/.local/bin`, project `bin/` folders, AppImages, portable
tools, and any scripts that don't ship a `.desktop` entry and therefore never
show up in the normal app drawer.

## Features

- Scan **one or more** directories (configured in settings).
- Optional **recursive** scanning of subdirectories.
- Launch **detached** (for GUI apps / background processes) or **in a terminal**
  (for CLI tools), configurable as the default with `Shift+Enter` doing the
  opposite.
- Uses the real app icon when a matching desktop entry exists, otherwise a
  generic terminal glyph.
- Fast substring search; type the trigger alone to browse everything.
- Manual **Rescan** entry to re-index after adding new binaries.

## Installation

### Manually

```sh
mkdir -p ~/.config/DankMaterialShell/plugins
cp -r BinaryLauncher ~/.config/DankMaterialShell/plugins/
```

Then in DMS:

1. Open Settings (`Ctrl+,` or `Mod+,`).
2. Go to the **Plugins** tab.
3. Click **Scan for Plugins**.
4. Toggle **Binary Launcher** on.

## Configuration

Open **Settings → Plugins → Binary Launcher**:

- **Directories** — add each directory to scan (absolute paths, or paths
  starting with `~`). Example: `~/bin`, `/usr/local/bin`.
- **Scan subdirectories** — index nested folders too (off by default; leave off
  for very large directories).
- **Default launch mode** — `Detached` (GUI/background) or `Run in terminal`.
- **Terminal command / exec flag** — the terminal used for terminal launches
  (e.g. `kitty` + `-e`, `gnome-terminal` + `--`, `wezterm` + `start`).
- **Trigger prefix** — the string that activates the plugin (default `$`), or
  enable **Always active** to search binaries with no prefix.

Settings are stored in `~/.config/DankMaterialShell/plugin_settings.json` under
the `binaryLauncher` key, for example:

```json
{
  "pluginSettings": {
    "binaryLauncher": {
      "trigger": "$",
      "alwaysActive": false,
      "recursive": false,
      "launchMode": "detached",
      "terminal": "kitty",
      "execFlag": "-e",
      "directories": [
        { "path": "~/bin" },
        { "path": "/usr/local/bin" }
      ]
    }
  }
}
```

## Usage

1. Open the launcher (`Ctrl+Space`).
2. Type your trigger, then a name — e.g. `$ btop`.
3. `Enter` launches with the default mode; `Shift+Enter` uses the opposite mode.
4. Type the trigger alone (`$`) to browse all indexed binaries and to **Rescan**.

## How it works

The plugin implements the DMS launcher contract in `BinaryLauncher.qml`:

- `getItems(query)` returns the matching binaries (and refreshes the index if the
  configured directories changed).
- `executeItem(item)` launches the selected binary via `Quickshell.execDetached`.
- Directory scanning uses the `Proc.runCommand` singleton to run
  `find -L <dir> -maxdepth N -type f -executable`, with each directory passed as
  a separate argument (never interpolated into the shell string) so paths with
  spaces or special characters are handled safely.

## Files

- `plugin.json` — plugin manifest (type `launcher`).
- `BinaryLauncher.qml` — launcher component (scan + list + launch).
- `BinaryLauncherSettings.qml` — settings UI.
- `README.md` — this file.

## Requirements

- DankMaterialShell `>= 0.1.18`.
- A Linux `find` supporting `-executable` and `-printf` (GNU findutils, standard
  on Linux desktops).
