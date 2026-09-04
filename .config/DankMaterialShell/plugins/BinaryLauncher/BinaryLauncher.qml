import QtQuick
import Quickshell
import qs.Common
import qs.Services

// Binary Launcher
// ---------------
// A DMS *launcher* plugin. It scans one or more user-configured directories for
// executable files and lists them in the launcher. Selecting an item launches
// the binary (detached, or inside a terminal, depending on settings).
//
// The launcher contract DMS expects from this component:
//   - property var pluginService     (injected by DMS, used for settings I/O)
//   - property string trigger        (read by DMS to know the activation prefix)
//   - signal itemsChanged()          (emit to ask DMS to re-query getItems)
//   - function getItems(query)       (return the array of launcher items)
//   - function executeItem(item)     (run the action for the selected item)
QtObject {
    id: root

    // Injected by DMS.
    property var pluginService: null

    // Activation prefix. Loaded from settings; DMS reads this property.
    property string trigger: "$"

    // --- Configuration mirror (kept in sync from plugin settings) ---
    property var directories: []          // array of absolute/`~` directory paths
    property string launchMode: "detached" // "detached" | "terminal"
    property bool recursive: false        // scan subdirectories too
    property string terminalCmd: "kitty"  // terminal used for terminal launches
    property string terminalExecFlag: "-e"
    property int maxResults: 200          // cap items returned to the launcher

    // --- Scan state ---
    property var binaries: []             // [{ name, path }]
    property bool scanning: false
    property bool hasScanned: false
    property string lastScanKey: ""       // dirs+recursive signature of last scan
    property var iconCache: ({})          // name -> resolved icon string

    signal itemsChanged

    Component.onCompleted: {
        loadConfig();
        scanBinaries();
    }

    // Re-read all settings into the local mirror. Returns true if the set of
    // directories (or the recursive flag) changed since the last scan, which
    // means a rescan is needed.
    function loadConfig() {
        if (!pluginService)
            return false;

        trigger = pluginService.loadPluginData("binaryLauncher", "trigger", "$");
        launchMode = pluginService.loadPluginData("binaryLauncher", "launchMode", "detached");
        recursive = pluginService.loadPluginData("binaryLauncher", "recursive", false);
        terminalCmd = pluginService.loadPluginData("binaryLauncher", "terminal", "kitty");
        terminalExecFlag = pluginService.loadPluginData("binaryLauncher", "execFlag", "-e");

        const raw = pluginService.loadPluginData("binaryLauncher", "directories", []);
        directories = normalizeDirectories(raw);

        const key = JSON.stringify(directories) + "|" + recursive;
        const changed = key !== lastScanKey;
        return changed;
    }

    // The directories setting is stored by ListSettingWithInput as an array of
    // objects like [{ path: "/usr/local/bin" }]. Accept plain strings too.
    function normalizeDirectories(raw) {
        const out = [];
        if (!Array.isArray(raw))
            return out;
        for (const entry of raw) {
            let p = "";
            if (typeof entry === "string")
                p = entry;
            else if (entry && typeof entry.path === "string")
                p = entry.path;
            p = (p || "").trim();
            if (p.length > 0)
                out.push(p);
        }
        return out;
    }

    // Kick off an asynchronous scan of every configured directory.
    function scanBinaries() {
        if (!pluginService)
            return;
        if (directories.length === 0) {
            binaries = [];
            hasScanned = true;
            scanning = false;
            lastScanKey = JSON.stringify(directories) + "|" + recursive;
            itemsChanged();
            return;
        }

        scanning = true;
        lastScanKey = JSON.stringify(directories) + "|" + recursive;

        // maxdepth 1 == just the directory itself; a big number == recursive.
        const maxdepth = recursive ? "25" : "1";

        // Directories are passed as separate argv entries (never interpolated
        // into the script text) so paths with spaces or shell metacharacters
        // are safe. `$0` is a throwaway ("sh").
        const script =
            'maxdepth="$1"; shift\n' +
            'for d in "$@"; do\n' +
            '  case "$d" in\n' +
            '    "~") d="$HOME" ;;\n' +
            '    "~/"*) d="$HOME/${d#"~"/}" ;;\n' +
            '  esac\n' +
            '  [ -d "$d" ] || continue\n' +
            '  find -L "$d" -maxdepth "$maxdepth" -type f -executable -printf "%f\\t%p\\n" 2>/dev/null\n' +
            'done | sort -u';

        const cmd = ["sh", "-c", script, "sh", maxdepth].concat(directories);

        Proc.runCommand("binaryLauncher.scan", cmd, (stdout, exitCode) => {
            const list = [];
            if (exitCode === 0 && stdout) {
                const lines = stdout.split("\n");
                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i];
                    if (!line)
                        continue;
                    const tab = line.indexOf("\t");
                    if (tab === -1)
                        continue;
                    const name = line.substring(0, tab);
                    const path = line.substring(tab + 1);
                    if (name && path)
                        list.push({ name: name, path: path });
                }
            }
            root.binaries = list;
            root.scanning = false;
            root.hasScanned = true;
            root.itemsChanged();
        }, 0);
    }

    // Resolve an icon for a binary. Prefer a matching desktop entry so GUI apps
    // get their real icon; fall back to a generic terminal glyph.
    function iconForName(name) {
        if (iconCache[name])
            return iconCache[name];

        let icon = "material:terminal";
        try {
            const entry = DesktopEntries.heuristicLookup(name);
            if (entry && entry.icon)
                icon = entry.icon;
        } catch (e) {
            // DesktopEntries may be unavailable; keep the fallback.
        }
        iconCache[name] = icon;
        return icon;
    }

    // Called by DMS every time the query changes.
    function getItems(query) {
        // Pick up settings edits (e.g. new directories) made while the launcher
        // component was already alive, and rescan when they change.
        if (pluginService) {
            const changed = loadConfig();
            if (changed && !scanning)
                scanBinaries();
        }

        const q = query ? query.toLowerCase().trim() : "";

        if (directories.length === 0) {
            return [{
                name: "No directories configured",
                icon: "material:folder_off",
                comment: "Open Settings → Plugins → Binary Launcher to add directories to scan",
                action: "noop:",
                categories: ["Binary Launcher"]
            }];
        }

        if (!hasScanned && scanning) {
            return [{
                name: "Scanning…",
                icon: "material:hourglass_empty",
                comment: "Indexing executables in your configured directories",
                action: "noop:",
                categories: ["Binary Launcher"]
            }];
        }

        const shiftHint = launchMode === "terminal"
            ? "Enter: run in terminal · Shift+Enter: run detached"
            : "Enter: launch · Shift+Enter: run in terminal";

        const items = [];
        for (let i = 0; i < binaries.length; i++) {
            const bin = binaries[i];
            if (q.length > 0 && bin.name.toLowerCase().indexOf(q) === -1)
                continue;

            items.push({
                name: bin.name,
                icon: iconForName(bin.name),
                comment: bin.path + "  ·  " + shiftHint,
                action: "run:" + bin.path,
                categories: ["Binary Launcher"]
            });

            if (items.length >= maxResults)
                break;
        }

        // Offer a manual rescan when browsing (no query typed).
        if (q.length === 0) {
            items.push({
                name: "Rescan directories",
                icon: "material:refresh",
                comment: binaries.length + " executable(s) indexed · click to refresh",
                action: "rescan:",
                categories: ["Binary Launcher"]
            });
        }

        return items;
    }

    // Called by DMS when the user activates an item (Enter / click).
    function executeItem(item) {
        if (!item || !item.action)
            return;

        const idx = item.action.indexOf(":");
        const type = idx === -1 ? item.action : item.action.substring(0, idx);
        const data = idx === -1 ? "" : item.action.substring(idx + 1);

        switch (type) {
        case "run":
            if (launchMode === "terminal")
                launchInTerminal(data);
            else
                launchDetached(data);
            break;
        case "rescan":
            iconCache = ({});
            scanBinaries();
            showToast("Rescanning directories…");
            break;
        case "noop":
            break;
        default:
            showToast("Unknown action: " + type);
        }
    }

    // Shift+Enter alternate action: run the opposite of the default launch mode.
    function getPasteArgs(item) {
        if (!item || !item.action)
            return null;
        if (item.action.indexOf("run:") !== 0)
            return null;
        const path = item.action.substring(4);
        if (!path)
            return null;

        if (launchMode === "terminal")
            return [path]; // default was terminal → alternate is detached
        return [terminalCmd, terminalExecFlag, path]; // alternate is terminal
    }

    function launchDetached(path) {
        if (!path)
            return;
        Quickshell.execDetached([path]);
        showToast("Launched: " + basename(path));
    }

    function launchInTerminal(path) {
        if (!path)
            return;
        // Keep the terminal open after the program exits so output is readable.
        const wrapped = quoteSingle(path) + "; echo; echo '[Press Enter to close]'; read _";
        Quickshell.execDetached([terminalCmd, terminalExecFlag, "sh", "-c", wrapped]);
        showToast("Running in terminal: " + basename(path));
    }

    function basename(path) {
        if (!path)
            return "";
        const parts = path.split("/");
        return parts[parts.length - 1] || path;
    }

    function quoteSingle(s) {
        // Safe single-quoting for embedding a path inside sh -c.
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    function showToast(message) {
        if (typeof ToastService !== "undefined")
            ToastService.showInfo("Binary Launcher", message);
    }

    onTriggerChanged: {
        if (pluginService)
            pluginService.savePluginData("binaryLauncher", "trigger", trigger);
    }
}

