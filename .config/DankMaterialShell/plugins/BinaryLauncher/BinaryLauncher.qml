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

    // Tokenize a binary's file name for matching. We go further than DMS's
    // native tokenizer: besides splitting on spaces, "-", "_" and ".", we also
    // break camelCase and letter/digit boundaries, so "GitHubDesktop" yields
    // ["git", "hub", "desktop"]. The file extension is appended as its own token.
    function splitTokens(name) {
        const spaced = name
            .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
            .replace(/([A-Za-z])([0-9])/g, "$1 $2")
            .replace(/([0-9])([A-Za-z])/g, "$1 $2");
        const out = [];
        const parts = spaced.split(/[\s\-_.]+/);
        for (let i = 0; i < parts.length; i++) {
            const t = parts[i].toLowerCase();
            if (t.length > 0)
                out.push(t);
        }
        const dot = name.lastIndexOf(".");
        if (dot > 0 && dot < name.length - 1)
            out.push(name.substring(dot + 1).toLowerCase());
        return out;
    }

    // Split a query into words on spaces, "-" and "_".
    function queryTokens(q) {
        return q.toLowerCase().trim().split(/[\s\-_]+/).filter(function (t) {
            return t.length > 0;
        });
    }

    // Score a binary name against the query, mirroring the feel of DMS's native
    // launcher matching but allowing the matched words to be non-consecutive
    // (an ordered prefix subsequence). Returns a positive score, or -1 for no
    // match. Higher is better; this becomes the item's _preScored value so DMS
    // keeps our result and preserves our ranking.
    function matchScore(name, qTokens, qJoined) {
        const ln = name.toLowerCase();
        if (qTokens.length === 0)
            return 0;
        if (ln === qJoined)
            return 10000;
        if (ln.startsWith(qJoined))
            return 6000;

        const tokens = splitTokens(name);
        let ti = 0;
        let first = -1;
        let last = -1;
        let prev = -1;
        let consec = 0;

        for (let qi = 0; qi < qTokens.length; qi++) {
            const qt = qTokens[qi];
            let found = -1;
            while (ti < tokens.length) {
                if (tokens[ti].indexOf(qt) === 0) {
                    found = ti;
                    ti++;
                    break;
                }
                ti++;
            }
            if (found === -1)
                return ln.indexOf(qJoined) !== -1 ? 400 : -1;
            if (first === -1)
                first = found;
            if (prev !== -1 && found === prev + 1)
                consec++;
            prev = found;
            last = found;
        }

        let s = 2500;
        if (first === 0)
            s += 800;             // match begins at the first word
        s += consec * 150;        // reward adjacency (closer to native behavior)
        s -= (last - first) * 10; // small penalty for spread-out matches
        s -= ln.length;           // gently prefer shorter names
        return s > 0 ? s : 1;
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
                categories: ["Binary Launcher"],
                _preScored: 1 // keep visible even while a query is typed
            }];
        }

        if (!hasScanned && scanning) {
            return [{
                name: "Scanning…",
                icon: "material:hourglass_empty",
                comment: "Indexing executables in your configured directories",
                action: "noop:",
                categories: ["Binary Launcher"],
                _preScored: 1
            }];
        }

        const shiftHint = launchMode === "terminal"
            ? "Enter: run in terminal · Shift+Enter: run detached"
            : "Enter: launch · Shift+Enter: run in terminal";

        const makeItem = function (bin) {
            return {
                name: bin.name,
                icon: iconForName(bin.name),
                comment: bin.path + "  ·  " + shiftHint,
                keywords: splitTokens(bin.name),
                action: "run:" + bin.path,
                categories: ["Binary Launcher"]
            };
        };

        // No query: browse everything (capped), plus a rescan entry.
        const qTokens = queryTokens(q);
        if (q.length === 0 || qTokens.length === 0) {
            const browse = [];
            for (let i = 0; i < binaries.length && browse.length < maxResults; i++)
                browse.push(makeItem(binaries[i]));

            browse.push({
                name: "Rescan directories",
                icon: "material:refresh",
                comment: binaries.length + " executable(s) indexed · click to refresh",
                action: "rescan:",
                categories: ["Binary Launcher"]
            });
            return browse;
        }

        // Query present: score with our own matcher, rank, cap, and pin the
        // result order via _preScored so DMS keeps exactly these items.
        const qJoined = q.replace(/\s+/g, "");
        const matches = [];
        for (let i = 0; i < binaries.length; i++) {
            const sc = matchScore(binaries[i].name, qTokens, qJoined);
            if (sc > 0)
                matches.push({ bin: binaries[i], score: sc });
        }

        matches.sort(function (a, b) {
            if (b.score !== a.score)
                return b.score - a.score;
            return a.bin.name.localeCompare(b.bin.name);
        });

        const items = [];
        const limit = Math.min(maxResults, matches.length);
        for (let i = 0; i < limit; i++) {
            const item = makeItem(matches[i].bin);
            item._preScored = matches[i].score;
            items.push(item);
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

