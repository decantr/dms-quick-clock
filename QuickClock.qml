import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.DCommon.Widgets

PluginComponent {
	id: root

	property bool use_24h: pluginData.use24h ?? true
	property bool pill_seconds: pluginData.pillSeconds ?? false

	property double now_ms: Date.now()
	property int popout_count: 0

	property bool sw_running: false
	property double sw_started_at: 0
	property double sw_accumulated: 0
	property var sw_laps: []

	readonly property double sw_elapsed: sw_running ? sw_accumulated + (now_ms - sw_started_at) : sw_accumulated
	readonly property bool sw_active: sw_running || sw_accumulated > 0

	onPluginServiceChanged: loadStopwatch()

	Timer {
		interval: root.popout_count > 0 && root.sw_running ? 16 : 1000
		repeat: true
		running: root.popout_count > 0 || root.sw_running || root.pill_seconds
		triggeredOnStart: true
		onTriggered: root.now_ms = Date.now()
	}

	Timer {
		interval: 30000
		repeat: true
		running: !root.pill_seconds && root.popout_count === 0 && !root.sw_running
		onTriggered: root.now_ms = Date.now()
	}

	function loadStopwatch() {
		if (!pluginService)
			return;
		sw_running = pluginService.loadPluginState("quickClock", "swRunning", false);
		sw_started_at = pluginService.loadPluginState("quickClock", "swStartedAt", 0);
		sw_accumulated = pluginService.loadPluginState("quickClock", "swAccumulated", 0);
		sw_laps = pluginService.loadPluginState("quickClock", "swLaps", []);
		now_ms = Date.now();
	}

	function saveStopwatch() {
		if (!pluginService)
			return;
		pluginService.savePluginState("quickClock", "swRunning", sw_running);
		pluginService.savePluginState("quickClock", "swStartedAt", sw_started_at);
		pluginService.savePluginState("quickClock", "swAccumulated", sw_accumulated);
		pluginService.savePluginState("quickClock", "swLaps", sw_laps);
	}

	function toggleStopwatch() {
		now_ms = Date.now();
		if (sw_running) {
			sw_accumulated += now_ms - sw_started_at;
			sw_running = false;
		} else {
			sw_started_at = now_ms;
			sw_running = true;
		}
		saveStopwatch();
	}

	function lapStopwatch() {
		if (!sw_running)
			return;
		now_ms = Date.now();
		const total = sw_elapsed;
		const previous = sw_laps.length > 0 ? sw_laps[0].total : 0;
		sw_laps = [
			{
				total: total,
				split: total - previous
			}
		].concat(sw_laps);
		saveStopwatch();
	}

	function resetStopwatch() {
		sw_running = false;
		sw_started_at = 0;
		sw_accumulated = 0;
		sw_laps = [];
		saveStopwatch();
	}

	function pad(value, width) {
		return String(value).padStart(width, "0");
	}

	function formatClock(ms, with_seconds) {
		const date = new Date(ms);
		let hours = date.getHours();
		let suffix = "";
		if (!use_24h) {
			suffix = hours >= 12 ? " PM" : " AM";
			hours = hours % 12 || 12;
		}
		const text = (use_24h ? pad(hours, 2) : String(hours)) + ":" + pad(date.getMinutes(), 2);
		return (with_seconds ? text + ":" + pad(date.getSeconds(), 2) : text) + suffix;
	}

	function formatDuration(ms, with_millis) {
		const total = Math.floor(ms / 1000);
		const hours = Math.floor(total / 3600);
		const text = (hours > 0 ? hours + ":" : "") + pad(Math.floor(total / 60) % 60, 2) + ":" + pad(total % 60, 2);
		return with_millis ? text + "." + pad(Math.floor(ms) % 1000, 3) : text;
	}

	function pillText() {
		if (sw_active)
			return formatDuration(sw_elapsed, false);
		return formatClock(now_ms, pill_seconds);
	}

	horizontalBarPill: Component {
		Row {
			spacing: Theme.spacingXS

			DIcon {
				name: root.sw_active ? "timer" : "schedule"
				size: root.iconSize
				color: root.sw_running ? Theme.primary : Theme.widgetTextColor
				anchors.verticalCenter: parent.verticalCenter
			}

			NumericText {
				text: root.pillText()
				font.features: ({ "tnum": 1 })
				isMonospace: false
				font.pixelSize: root.textSize
				font.weight: Font.Medium
				color: Theme.widgetTextColor
				anchors.verticalCenter: parent.verticalCenter
			}
		}
	}

	verticalBarPill: Component {
		Column {
			spacing: Theme.spacingXS

			DIcon {
				name: root.sw_active ? "timer" : "schedule"
				size: root.iconSize
				color: root.sw_running ? Theme.primary : Theme.widgetTextColor
				anchors.horizontalCenter: parent.horizontalCenter
			}

			NumericText {
				text: root.pillText()
				font.features: ({ "tnum": 1 })
				isMonospace: false
				font.pixelSize: root.textSize
				color: Theme.widgetTextColor
				horizontalAlignment: Text.AlignHCenter
				anchors.horizontalCenter: parent.horizontalCenter
			}
		}
	}

	popoutWidth: 360

	popoutContent: Component {
		PopoutComponent {
			headerText: "Quick Clock"
			detailsText: Qt.formatDate(new Date(root.now_ms), "dddd, d MMMM yyyy")
			showCloseButton: true

			Component.onCompleted: root.popout_count += 1
			Component.onDestruction: root.popout_count -= 1

			Column {
				width: parent.width
				spacing: Theme.spacingM

				StyledText {
					text: root.formatClock(root.now_ms, true)
					font.pixelSize: Theme.fontSizeXLarge * 2
					font.weight: Font.Medium
					font.features: ({ "tnum": 1 })
					color: Theme.surfaceText
					anchors.horizontalCenter: parent.horizontalCenter
				}

				StyledRect {
					width: parent.width
					height: stopwatchColumn.implicitHeight + Theme.spacingL * 2
					radius: Theme.cornerRadius
					color: Theme.surfaceContainerHigh

					Column {
						id: stopwatchColumn
						anchors.fill: parent
						anchors.margins: Theme.spacingL
						spacing: Theme.spacingM

						StyledText {
							text: "Stopwatch"
							font.pixelSize: Theme.fontSizeSmall
							color: Theme.surfaceVariantText
						}

						StyledText {
							text: root.formatDuration(root.sw_elapsed, true)
							font.pixelSize: Theme.fontSizeXLarge * 1.5
							font.weight: Font.Medium
							font.features: ({ "tnum": 1 })
							color: root.sw_running ? Theme.primary : Theme.surfaceText
							anchors.horizontalCenter: parent.horizontalCenter
						}

						Row {
							spacing: Theme.spacingS
							anchors.horizontalCenter: parent.horizontalCenter

							DButton {
								text: root.sw_running ? "Pause" : (root.sw_active ? "Resume" : "Start")
								iconName: root.sw_running ? "pause" : "play_arrow"
								onClicked: root.toggleStopwatch()
							}

							DButton {
								text: "Lap"
								iconName: "flag"
								enabled: root.sw_running
								onClicked: root.lapStopwatch()
							}

							DButton {
								text: "Reset"
								iconName: "restart_alt"
								enabled: root.sw_active
								onClicked: root.resetStopwatch()
							}
						}

						Column {
							width: parent.width
							spacing: Theme.spacingXS
							visible: root.sw_laps.length > 0

							Repeater {
								model: root.sw_laps.slice(0, 5)

								Row {
									width: parent.width
									spacing: Theme.spacingM

									StyledText {
										width: parent.width * 0.2
										text: "#" + (root.sw_laps.length - index)
										font.pixelSize: Theme.fontSizeSmall
										color: Theme.surfaceVariantText
									}

									StyledText {
										width: parent.width * 0.35
										text: "+" + root.formatDuration(modelData.split, true)
										font.pixelSize: Theme.fontSizeSmall
										font.features: ({ "tnum": 1 })
										color: Theme.surfaceText
									}

									StyledText {
										text: root.formatDuration(modelData.total, true)
										font.pixelSize: Theme.fontSizeSmall
										font.features: ({ "tnum": 1 })
										color: Theme.surfaceVariantText
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
