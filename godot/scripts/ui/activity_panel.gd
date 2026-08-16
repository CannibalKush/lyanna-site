class_name ActivityPanel
extends PanelContainer

signal activity_selected(system_id: String, activity: Dictionary)
signal repeat_toggled

var title: Label
var description: Label
var currency: Label
var level: Label
var list: VBoxContainer
var active_label: Label
var active_detail: Label
var active_bar: ProgressBar
var repeat_button: Button
var toast_label: Label

func build() -> void:
	add_theme_stylebox_override("panel", UiFactory.style(Color("#242024"), Color("#4b443c"), 1, 12))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	title = UiFactory.label("", 28, Color("#eee8d4"))
	header.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	level = UiFactory.label("", 14, Color("#d7c56d"))
	header.add_child(level)
	description = UiFactory.label("", 14, Color("#9c9587"))
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(description)
	currency = UiFactory.label("", 12, Color("#d7c56d"))
	box.add_child(currency)
	box.add_child(HSeparator.new())
	box.add_child(UiFactory.label("CHOOSE AN ACTIVITY", 11, Color("#d7c56d")))
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 7)
	box.add_child(list)
	box.add_child(HSeparator.new())
	active_label = UiFactory.label("No activity selected", 18, Color("#eee8d4"))
	box.add_child(active_label)
	active_detail = UiFactory.label("Choose an activity to begin.", 12, Color("#9c9587"))
	active_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(active_detail)
	active_bar = ProgressBar.new()
	active_bar.custom_minimum_size.y = 16
	active_bar.show_percentage = false
	active_bar.add_theme_stylebox_override("background", UiFactory.style(Color("#302c2b"), Color.TRANSPARENT, 0, 8))
	active_bar.add_theme_stylebox_override("fill", UiFactory.style(Color("#d7c56d"), Color.TRANSPARENT, 0, 8))
	box.add_child(active_bar)
	repeat_button = UiFactory.button("AUTO REPEAT: OFF", Color("#9c9587"), Color("#100f12"))
	repeat_button.pressed.connect(repeat_toggled.emit)
	box.add_child(repeat_button)
	toast_label = UiFactory.label("", 13, Color("#d7c56d"))
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(toast_label)

func update_system(system: Dictionary, state: Dictionary, pending: Dictionary, active_id: String, can_afford: Callable, flow: Callable) -> void:
	var system_state: Dictionary = state.systems[active_id]
	title.text = "%s  %s" % [system.get("glyph", "·"), system.name]
	description.text = system.description
	currency.text = "SYSTEM CURRENCY  /  %s" % str(system.currency).to_upper()
	level.text = "LEVEL %02d" % int(system_state.level)
	for child in list.get_children():
		child.queue_free()
	for raw_activity in system.activities:
		var activity: Dictionary = raw_activity
		var key := "%s:%s" % [active_id, activity.id]
		var unlocked: bool = bool(state.unlocked_activities.get(key, false))
		var ready: bool = unlocked and bool(can_afford.call(activity))
		var button := UiFactory.button("%s  |  %s  |  %s" % [activity.name, flow.call(activity), "READY" if ready else "NEEDS MATERIALS"], Color("#eee8d4") if unlocked else Color("#9c9587"), Color("#1b191b"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = not ready or not pending.is_empty()
		button.tooltip_text = activity.detail
		button.pressed.connect(activity_selected.emit.bind(active_id, activity))
		list.add_child(button)

func update_active(active_task: Dictionary, progress: float) -> void:
	if active_task.is_empty():
		active_label.text = "No activity selected"
		active_detail.text = "Choose an activity to begin."
		active_bar.value = 0.0
	else:
		var activity: Dictionary = active_task.activity
		active_label.text = "%s   %02d%%" % [activity.name, int(progress)]
		active_detail.text = activity.detail
		active_bar.value = progress

func set_repeat(enabled: bool) -> void:
	repeat_button.text = "AUTO REPEAT: %s" % ("ON" if enabled else "OFF")
	repeat_button.add_theme_color_override("font_color", Color("#d7c56d") if enabled else Color("#9c9587"))

func show_toast(message: String) -> void:
	toast_label.text = message
