class_name GameHud
extends Control

signal menu_pressed

var day_label: Label
var currency_label: Label
var overall_label: Label
var overall_bar: ProgressBar

func build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top_bar := PanelContainer.new()
	top_bar.add_theme_stylebox_override("panel", UiFactory.style(Color("#1b191b"), Color("#4b443c"), 1, 12))
	add_child(top_bar)
	var top_box := HBoxContainer.new()
	top_bar.add_child(top_box)
	day_label = UiFactory.label("DAY 01", 13, Color("#d7c56d"))
	top_box.add_child(day_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_box.add_child(spacer)
	currency_label = UiFactory.label("", 12, Color("#9c9587"))
	top_box.add_child(currency_label)
	var menu := UiFactory.button("MENU", Color("#9c9587"), Color("#100f12"))
	menu.custom_minimum_size = Vector2(72, 34)
	menu.pressed.connect(menu_pressed.emit)
	top_box.add_child(menu)
	overall_label = UiFactory.label("PATH XP  /  0", 10, Color("#d7c56d"))
	overall_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(overall_label)
	overall_bar = ProgressBar.new()
	overall_bar.show_percentage = false
	overall_bar.add_theme_stylebox_override("background", UiFactory.style(Color("#302c2b"), Color.TRANSPARENT, 0, 6))
	overall_bar.add_theme_stylebox_override("fill", UiFactory.style(Color("#a76f56"), Color.TRANSPARENT, 0, 6))
	add_child(overall_bar)

func update_state(state: Dictionary) -> void:
	var currencies: Dictionary = state.currencies
	currency_label.text = "R %02d  ·  W %02d  ·  C %02d  ·  M %02d  ·  F %02d  ·  S %02d" % [currencies.reeds, currencies.water, currencies.clay, currencies.calm, currencies.focus, currencies.silver]
	var path_xp: int = int(state.get("overall_xp", 0))
	overall_label.text = "PATH XP  /  RANK %02d  /  %03d%%" % [path_xp / 100, path_xp % 100]
	overall_bar.value = float(path_xp % 100)
	day_label.text = "DAY %02d" % int(state.day)

func layout(width: float, margin: float, top_height: float) -> void:
	var top_bar := get_child(0) as Control
	top_bar.position = Vector2(margin, margin)
	top_bar.size = Vector2(width - margin * 2.0, top_height)
	var top_child := top_bar.get_child(0) as Control
	top_child.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overall_bar.position = Vector2(margin, margin + top_height + 8.0)
	overall_bar.size = Vector2(width - margin * 2.0, 10.0)
	overall_label.position = Vector2(margin, margin + top_height - 4.0)
	overall_label.size = Vector2(width - margin * 2.0, 18.0)
