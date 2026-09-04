import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "binaryLauncher"

    Component.onCompleted: {
        // Normalize a legacy/empty trigger unless the user chose "always active".
        const alwaysActive = root.loadValue("alwaysActive", false);
        const currentTrigger = root.loadValue("trigger", "$");
        if (!alwaysActive && (!currentTrigger || currentTrigger.trim().length === 0))
            root.saveValue("trigger", "$");
    }

    StyledText {
        width: parent.width
        text: "Binary Launcher"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Scan one or more directories for executable files and launch them straight from the launcher."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    // --- Directories ----------------------------------------------------------
    StyledText {
        width: parent.width
        text: "Directories to scan"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    ListSettingWithInput {
        width: parent.width
        settingKey: "directories"
        label: "Directories"
        description: "Add absolute paths (or paths starting with ~). Every executable file found in these directories is added to the launcher."
        defaultValue: []
        fields: [
            {
                id: "path",
                label: "Directory path",
                placeholder: "/usr/local/bin  or  ~/bin",
                width: 320,
                required: true
            }
        ]
    }

    ToggleSetting {
        width: parent.width
        settingKey: "recursive"
        label: "Scan subdirectories"
        description: "Also index executables in nested folders. Leave off for large directories like /usr/bin to keep scans fast."
        defaultValue: false
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    // --- Launch behavior ------------------------------------------------------
    StyledText {
        width: parent.width
        text: "Launch behavior"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    SelectionSetting {
        width: parent.width
        settingKey: "launchMode"
        label: "Default launch mode"
        description: "How binaries run on Enter. Shift+Enter always does the opposite."
        options: [
            { label: "Detached (GUI / background)", value: "detached" },
            { label: "Run in terminal", value: "terminal" }
        ]
        defaultValue: "detached"
    }

    StringSetting {
        width: parent.width
        settingKey: "terminal"
        label: "Terminal command"
        description: "Terminal emulator used for terminal launches (e.g. kitty, alacritty, foot, wezterm, gnome-terminal, konsole)."
        placeholder: "kitty"
        defaultValue: "kitty"
    }

    StringSetting {
        width: parent.width
        settingKey: "execFlag"
        label: "Terminal exec flag"
        description: "Flag your terminal uses to run a command. Common: -e (kitty/alacritty/foot/konsole), -- (gnome-terminal), start (wezterm)."
        placeholder: "-e"
        defaultValue: "-e"
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    // --- Trigger --------------------------------------------------------------
    StyledText {
        width: parent.width
        text: "Trigger"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    ToggleSetting {
        id: alwaysActiveToggle
        width: parent.width
        settingKey: "alwaysActive"
        label: "Always active (no trigger)"
        description: value
            ? "Binaries are searched alongside apps with no prefix. Note: this can add a lot of entries to normal launcher searches."
            : "Type the trigger prefix to search binaries only."
        defaultValue: false
        onValueChanged: {
            if (value)
                root.saveValue("trigger", "");
            else
                root.saveValue("trigger", triggerSetting.value || "$");
        }
    }

    StringSetting {
        id: triggerSetting
        width: parent.width
        visible: !alwaysActiveToggle.value
        settingKey: "trigger"
        label: "Trigger prefix"
        description: "Type this in the launcher to show binaries (e.g. $, !, run). Avoid prefixes reserved by DMS or other plugins (like / for file search)."
        placeholder: "$"
        defaultValue: "$"
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    // --- Usage ----------------------------------------------------------------
    StyledText {
        width: parent.width
        text: "Usage"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Medium
        color: Theme.surfaceText
    }

    Column {
        width: parent.width
        spacing: Theme.spacingXS
        leftPadding: Theme.spacingM
        bottomPadding: Theme.spacingL

        Repeater {
            model: [
                "1. Add one or more directories above.",
                "2. Open the launcher (Ctrl+Space).",
                "3. Type your trigger, then a name: e.g. '$ btop'.",
                "4. Enter launches; Shift+Enter uses the opposite launch mode.",
                "5. Type the trigger alone to browse everything and rescan."
            ]

            StyledText {
                required property string modelData
                width: parent.width
                text: modelData
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
            }
        }
    }
}
