import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
	id: root

	pluginId: "quickClock"

	ToggleSetting {
		settingKey: "use24h"
		label: I18n.tr("24-hour clock")
		description: I18n.tr("Show 13:45 instead of 1:45 PM")
		defaultValue: true
	}

	ToggleSetting {
		settingKey: "pillSeconds"
		label: I18n.tr("Seconds in bar")
		description: I18n.tr("Tick every second in the bar, not only while the popout is open")
		defaultValue: false
	}
}
