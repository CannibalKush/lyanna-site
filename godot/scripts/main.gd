extends Control
## Ego Incremental: a small living system of work, attention, and revelation.
## Content comes from data/systems.json. The interface only sends player intent.

const DATA_PATH := "res://data/systems.json"
const SAVE_PATH := "user://ego_incremental.json"
const BG := Color("#100f12")
const INK := Color("#eee8d4")
const MUTED := Color("#9c9587")
const REED := Color("#d7c56d")
const CLAY := Color("#a76f56")
const LAPIS := Color("#7096bd")
const VIOLET := Color("#ad8bc4")
const LINE := Color("#4b443c")
const PANEL := Color("#1b191b")
const PANEL_RAISED := Color("#242024")

var systems: Array = []
var state: Dictionary = {}
var active_system_id := "gathering"
var active_task: Dictionary = {}
var last_activity: Dictionary = {}
var repeat_enabled := false
var task_progress := 0.0
var elapsed := 0.0
var pending_reward: Dictionary = {}
var toast_timer := 0.0
var toast_text := ""

var menu_layer: Control
var menu_panel: PanelContainer
var game_layer: Control
var nav_panel: PanelContainer
var content_panel: PanelContainer
var top_bar: PanelContainer
var nav_list: VBoxContainer
var content_box: VBoxContainer
var system_title: Label
var system_description: Label
var system_currency: Label
var activity_list: VBoxContainer
var level_label: Label
var xp_label: Label
var xp_bar: ProgressBar
var active_label: Label
var active_detail: Label
var active_bar: ProgressBar
var reward_panel: PanelContainer
var reward_box: VBoxContainer
var repeat_button: Button
var toast_label: Label
var currency_label: Label
var day_label: Label

func _ready() -> void:
	_load_content()
	_load_state()
	_build_menu()
	_build_game()
	_show_menu()
	get_viewport().size_changed.connect(_layout)
	_layout()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if toast_timer > 0.0:
		toast_timer -= delta
		if toast_timer <= 0.0:
			toast_label.text = ""
	if not active_task.is_empty() and pending_reward.is_empty():
		var system_id: String = active_task.get("system_id", "")
		var activity: Dictionary = active_task.get("activity", {})
		var duration: float = float(activity.get("duration", 1.0)) * _duration_multiplier(system_id)
		task_progress += delta
		var percent: float = minf(100.0, task_progress / duration * 100.0)
		active_bar.value = percent
		active_label.text = "%s   %02d%%" % [activity.get("name", "Working"), int(percent)]
		if task_progress >= duration:
			_finish_activity()
	_update_world()
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	var tablet := Rect2(18.0, 78.0, maxf(1.0, size.x - 36.0), maxf(1.0, size.y - 96.0))
	draw_style_box(_style(Color(0.20, 0.16, 0.13, 0.12), Color(0.42, 0.33, 0.22, 0.30), 1, 14), tablet)
	for index in 22:
		var x: float = fmod(float(index * 113) + elapsed * (1.0 + float(index % 2)), maxf(1.0, size.x))
		var y: float = 80.0 + fmod(float(index * 67), maxf(1.0, size.y - 100.0))
		draw_circle(Vector2(x, y), 1.0 + float(index % 2), Color(0.82, 0.73, 0.38, 0.15))

func _load_content() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		systems = parsed.get("systems", []) as Array

func _load_state() -> void:
	state = {
		"version": 1,
		"day": 1,
		"currencies": {"reeds": 0, "water": 0, "clay": 0, "calm": 0, "focus": 8, "insight": 0, "silver": 0, "reputation": 0},
		"systems": {},
		"effects": {},
		"unlocked_activities": {"gathering:reeds": true, "gathering:water": true}
	}
	for raw_system in systems:
		var system: Dictionary = raw_system
		state.systems[system.id] = {"level": 1, "xp": 0, "actions": 0}
	if not FileAccess.file_exists(SAVE_PATH):
		_ensure_default_unlocks()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var loaded: Variant = JSON.parse_string(file.get_as_text())
	if loaded is Dictionary and int(loaded.get("version", 0)) == 1:
		state = loaded
	_ensure_default_unlocks()

func _ensure_default_unlocks() -> void:
	if not state.has("unlocked_activities"):
		state["unlocked_activities"] = {}
	for raw_system in systems:
		var system: Dictionary = raw_system
		if not _is_system_unlocked(system.id):
			continue
		var activities: Array = system.get("activities", []) as Array
		for index in activities.size():
			var activity: Dictionary = activities[index]
			var key := "%s:%s" % [system.id, activity.id]
			if not state.unlocked_activities.has(key):
				state.unlocked_activities[key] = index < 1 or system.id == "gathering" and index < 2

func _save_state() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state))

func _build_menu() -> void:
	menu_layer = Control.new()
	menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_layer)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(center)
	menu_panel = PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(500, 380)
	menu_panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 18))
	center.add_child(menu_panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	menu_panel.add_child(box)
	box.add_child(_label("THE TABLET REMEMBERS", 12, REED))
	box.add_child(_label("Ego\nIncremental", 42, INK))
	var intro := _label("Begin with hunger.\nEnd somewhere stranger.", 18, MUTED)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(intro)
	var space := Control.new()
	space.custom_minimum_size.y = 22
	box.add_child(space)
	var start := _button("BEGIN YOUR FIRST DAY", REED, BG)
	start.pressed.connect(_start_game)
	box.add_child(start)
	var note := _label("Gather. Attend. Speak. Exchange.\nThe old gods prefer patient people.", 12, MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(note)

func _build_game() -> void:
	game_layer = Control.new()
	game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_layer)
	top_bar = PanelContainer.new()
	top_bar.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 12))
	game_layer.add_child(top_bar)
	var top_box := HBoxContainer.new()
	top_bar.add_child(top_box)
	day_label = _label("DAY 01", 13, REED)
	top_box.add_child(day_label)
	var top_space := Control.new()
	top_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_box.add_child(top_space)
	currency_label = _label("", 12, MUTED)
	top_box.add_child(currency_label)

	nav_panel = PanelContainer.new()
	nav_panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 12))
	game_layer.add_child(nav_panel)
	var nav_box := VBoxContainer.new()
	nav_box.add_theme_constant_override("separation", 7)
	nav_panel.add_child(nav_box)
	nav_box.add_child(_label("THE SYSTEMS", 11, REED))
	nav_list = VBoxContainer.new()
	nav_list.add_theme_constant_override("separation", 5)
	nav_box.add_child(nav_list)
	var nav_hint := _label("Unlock the next door by\nlearning the one before it.", 11, MUTED)
	nav_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nav_box.add_child(nav_hint)

	content_panel = PanelContainer.new()
	content_panel.add_theme_stylebox_override("panel", _style(PANEL_RAISED, LINE, 1, 12))
	game_layer.add_child(content_panel)
	content_box = VBoxContainer.new()
	content_box.add_theme_constant_override("separation", 12)
	content_panel.add_child(content_box)
	var header := HBoxContainer.new()
	content_box.add_child(header)
	system_title = _label("", 28, INK)
	header.add_child(system_title)
	var header_space := Control.new()
	header_space.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_space)
	level_label = _label("", 14, REED)
	header.add_child(level_label)
	system_description = _label("", 14, MUTED)
	system_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(system_description)
	system_currency = _label("", 12, REED)
	content_box.add_child(system_currency)
	var line := HSeparator.new()
	content_box.add_child(line)
	content_box.add_child(_label("CHOOSE AN ACTIVITY", 11, REED))
	activity_list = VBoxContainer.new()
	activity_list.add_theme_constant_override("separation", 7)
	content_box.add_child(activity_list)
	var active_line := HSeparator.new()
	content_box.add_child(active_line)
	active_label = _label("No activity selected", 18, INK)
	content_box.add_child(active_label)
	active_detail = _label("Choose a system activity to begin.", 12, MUTED)
	active_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(active_detail)
	active_bar = ProgressBar.new()
	active_bar.custom_minimum_size.y = 16
	active_bar.show_percentage = false
	active_bar.add_theme_stylebox_override("background", _style(Color("#302c2b"), Color.TRANSPARENT, 0, 8))
	active_bar.add_theme_stylebox_override("fill", _style(REED, Color.TRANSPARENT, 0, 8))
	content_box.add_child(active_bar)
	repeat_button = _button("AUTO REPEAT: OFF", MUTED, BG)
	repeat_button.pressed.connect(_toggle_repeat)
	content_box.add_child(repeat_button)
	toast_label = _label("", 13, REED)
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_box.add_child(toast_label)
	_build_reward_panel()
	_refresh_navigation()
	_select_system("gathering")

func _build_reward_panel() -> void:
	reward_panel = PanelContainer.new()
	reward_panel.visible = false
	reward_panel.add_theme_stylebox_override("panel", _style(Color("#302b1d"), REED, 1, 12))
	game_layer.add_child(reward_panel)
	reward_box = VBoxContainer.new()
	reward_box.add_theme_constant_override("separation", 8)
	reward_panel.add_child(reward_box)

func _start_game() -> void:
	_show_game()
	_select_system("gathering")
	_show_toast("The first day begins. The river is low.")

func _select_system(system_id: String) -> void:
	if not _is_system_unlocked(system_id):
		_show_toast("This door is still closed.")
		return
	active_system_id = system_id
	active_task = {}
	task_progress = 0.0
	_refresh_navigation()
	_refresh_system()

func _refresh_navigation() -> void:
	if not nav_list:
		return
	_ensure_default_unlocks()
	for child in nav_list.get_children():
		child.queue_free()
	for raw_system in systems:
		var system: Dictionary = raw_system
		var unlocked := _is_system_unlocked(system.id)
		var level: int = int(state.systems.get(system.id, {}).get("level", 1))
		var button := _button("%s  %s  %s" % [system.get("glyph", "·"), system.name, "LV %02d" % level if unlocked else "LOCKED"], REED if unlocked else MUTED, PANEL if system.id != active_system_id else Color("#3b3527"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = not unlocked
		button.tooltip_text = system.description
		button.pressed.connect(_select_system.bind(system.id))
		nav_list.add_child(button)

func _refresh_system() -> void:
	var system: Dictionary = _get_system(active_system_id)
	if system.is_empty():
		return
	var system_state: Dictionary = state.systems[active_system_id]
	system_title.text = "%s  %s" % [system.get("glyph", "·"), system.name]
	system_description.text = system.description
	system_currency.text = "SYSTEM CURRENCY  /  %s" % str(system.currency).to_upper()
	level_label.text = "LEVEL %02d" % int(system_state.level)
	for child in activity_list.get_children():
		child.queue_free()
	for raw_activity in system.activities:
		var activity: Dictionary = raw_activity
		var key := "%s:%s" % [active_system_id, activity.id]
		var unlocked := bool(state.unlocked_activities.get(key, false))
		var can_start := unlocked and _can_afford(activity)
		var label_text := "%s   ·   %s" % [activity.name, "READY" if can_start else "NEEDS MATERIALS"]
		var button := _button(label_text, INK if unlocked else MUTED, PANEL)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = not can_start or not pending_reward.is_empty()
		button.tooltip_text = activity.detail
		button.pressed.connect(_start_activity.bind(active_system_id, activity))
		activity_list.add_child(button)
	if active_task.is_empty():
		active_label.text = "No activity selected"
		active_detail.text = "Choose an activity to begin."
		active_bar.value = 0.0
	_update_world()

func _update_world() -> void:
	if not currency_label:
		return
	var currencies: Dictionary = state.currencies
	currency_label.text = "R %02d  ·  W %02d  ·  C %02d  ·  M %02d  ·  F %02d  ·  S %02d" % [currencies.reeds, currencies.water, currencies.clay, currencies.calm, currencies.focus, currencies.silver]
	day_label.text = "DAY %02d" % int(state.day)
	if not active_task.is_empty():
		var activity: Dictionary = active_task.activity
		active_detail.text = activity.detail
	_refresh_reward_panel()

func _start_activity(system_id: String, activity: Dictionary) -> void:
	if not _can_afford(activity) or not pending_reward.is_empty() or not active_task.is_empty():
		return
	_pay_costs(activity)
	last_activity = {"system_id": system_id, "activity": activity}
	active_task = last_activity.duplicate()
	task_progress = 0.0
	active_bar.value = 0.0
	_show_toast("%s begins." % activity.name)
	_refresh_system()

func _toggle_repeat() -> void:
	if last_activity.is_empty():
		_show_toast("Complete an activity before automating it.")
		return
	repeat_enabled = not repeat_enabled
	repeat_button.text = "AUTO REPEAT: %s" % ("ON" if repeat_enabled else "OFF")
	repeat_button.add_theme_color_override("font_color", REED if repeat_enabled else MUTED)
	_show_toast("The routine is %s." % ("awake" if repeat_enabled else "quiet"))
	if repeat_enabled and active_task.is_empty() and pending_reward.is_empty():
		_start_activity(last_activity.system_id, last_activity.activity)

func _finish_activity() -> void:
	var system_id: String = active_task.system_id
	var activity: Dictionary = active_task.activity
	var system_state: Dictionary = state.systems[system_id]
	var multiplier: float = _yield_multiplier(system_id)
	for raw_reward in activity.get("rewards", []):
		var reward: Dictionary = raw_reward
		var amount: int = maxi(1, roundi(float(reward.amount) * multiplier))
		if _roll_critical(system_id):
			amount *= 2
		_add_currency(reward.currency, amount)
	var xp_gain: int = maxi(1, roundi(float(activity.xp) * _xp_multiplier(system_id)))
	system_state.xp = int(system_state.xp) + xp_gain
	system_state.actions = int(system_state.actions) + 1
	var levelled := false
	while int(system_state.xp) >= _xp_needed(int(system_state.level)):
		system_state.xp = int(system_state.xp) - _xp_needed(int(system_state.level))
		system_state.level = int(system_state.level) + 1
		levelled = true
		var system: Dictionary = _get_system(system_id)
		var choices: Array = system.get("rewards", {}).get(str(system_state.level), []) as Array
		if not choices.is_empty():
			pending_reward = {"system_id": system_id, "level": system_state.level, "choices": choices}
			active_task = {}
			_show_toast("A new understanding arrives.")
			break
	if not levelled:
		_show_toast("%s  +%d XP" % [activity.name, xp_gain])
	var should_repeat: bool = pending_reward.is_empty() and repeat_enabled and not last_activity.is_empty() and _can_afford(last_activity.activity)
	active_task = {}
	_save_state()
	_refresh_navigation()
	_refresh_system()
	if should_repeat:
		_start_activity(last_activity.system_id, last_activity.activity)

func _refresh_reward_panel() -> void:
	if reward_panel == null:
		return
	reward_panel.visible = not pending_reward.is_empty()
	for child in reward_box.get_children():
		child.queue_free()
	if pending_reward.is_empty():
		return
	reward_box.add_child(_label("LEVEL %02d UNDERSTANDING" % int(pending_reward.level), 13, REED))
	reward_box.add_child(_label("Choose what this system teaches you.", 12, MUTED))
	var choices: Array = pending_reward.choices
	for raw_choice in choices:
		var choice: Dictionary = raw_choice
		var button := _button("%s  /  %s" % [choice.label, choice.detail], INK, PANEL)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_choose_reward.bind(choice))
		reward_box.add_child(button)

func _choose_reward(choice: Dictionary) -> void:
	var system_id: String = pending_reward.system_id
	var effects: Dictionary = state.effects
	var key := "%s:%s" % [system_id, choice.kind]
	effects[key] = effects.get(key, 0.0) + float(choice.value)
	if choice.kind == "unlock_activity":
		state.unlocked_activities["%s:%s" % [system_id, choice.value]] = true
	pending_reward = {}
	_show_toast("%s becomes part of your practice." % choice.label)
	_save_state()
	_refresh_navigation()
	_refresh_system()

func _get_system(system_id: String) -> Dictionary:
	for raw_system in systems:
		var system: Dictionary = raw_system
		if system.id == system_id:
			return system
	return {}

func _is_system_unlocked(system_id: String) -> bool:
	var system := _get_system(system_id)
	if system.is_empty() or not system.has("requirements"):
		return true
	var requirement: Dictionary = system.requirements
	var required_state: Dictionary = state.systems.get(requirement.system, {})
	return int(required_state.get("level", 0)) >= int(requirement.level)

func _can_afford(activity: Dictionary) -> bool:
	for raw_cost in activity.get("costs", []):
		var cost: Dictionary = raw_cost
		var reduction: int = int(state.effects.get("%s:cost_reduction" % active_system_id, 0))
		var amount: int = maxi(0, int(cost.amount) - reduction)
		if int(state.currencies.get(cost.currency, 0)) < amount:
			return false
	return true

func _pay_costs(activity: Dictionary) -> void:
	for raw_cost in activity.get("costs", []):
		var cost: Dictionary = raw_cost
		var reduction: int = int(state.effects.get("%s:cost_reduction" % active_system_id, 0))
		var amount: int = maxi(0, int(cost.amount) - reduction)
		_add_currency(cost.currency, -amount)

func _add_currency(currency: String, amount: int) -> void:
	state.currencies[currency] = maxi(0, int(state.currencies.get(currency, 0)) + amount)

func _xp_needed(level: int) -> int:
	return 12 + level * 10

func _duration_multiplier(system_id: String) -> float:
	var speed: float = float(state.effects.get("%s:speed" % system_id, 0.0))
	return 1.0 / (1.0 + speed)

func _xp_multiplier(system_id: String) -> float:
	return 1.0 + float(state.effects.get("%s:xp" % system_id, 0.0))

func _yield_multiplier(system_id: String) -> float:
	return 1.0 + float(state.effects.get("%s:yield" % system_id, 0.0))

func _roll_critical(system_id: String) -> bool:
	var chance: float = float(state.effects.get("%s:critical" % system_id, 0.0))
	return randf() < chance

func _show_toast(message: String) -> void:
	toast_text = message
	toast_timer = 4.0
	if toast_label:
		toast_label.text = message

func _show_menu() -> void:
	menu_layer.visible = true
	game_layer.visible = false

func _show_game() -> void:
	menu_layer.visible = false
	game_layer.visible = true

func _layout() -> void:
	if not game_layer:
		return
	var width: float = size.x
	var height: float = size.y
	var margin: float = 18.0 if width >= 760.0 else 10.0
	var top_height: float = 54.0
	top_bar.position = Vector2(margin, margin)
	top_bar.size = Vector2(width - margin * 2.0, top_height)
	var top_child := top_bar.get_child(0) as Control
	if top_child:
		top_child.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var top_y: float = margin + top_height + 14.0
	var compact_width: bool = width < 800.0
	var short_screen: bool = height < 560.0
	var desktop_layout: bool = not compact_width or (width >= 640.0 and short_screen)
	if desktop_layout:
		var nav_width: float = 280.0 if width >= 800.0 else 220.0
		nav_panel.position = Vector2(margin, top_y)
		nav_panel.size = Vector2(nav_width, height - top_y - margin)
		content_panel.position = Vector2(margin + nav_width + 14.0, top_y)
		content_panel.size = Vector2(width - margin * 2.0 - nav_width - 14.0, height - top_y - margin)
	else:
		var nav_height: float = 252.0
		nav_panel.position = Vector2(margin, top_y)
		nav_panel.size = Vector2(width - margin * 2.0, nav_height)
		content_panel.position = Vector2(margin, top_y + nav_height + 12.0)
		content_panel.size = Vector2(width - margin * 2.0, maxf(220.0, height - top_y - nav_height - margin - 12.0))
	if menu_panel:
		menu_panel.custom_minimum_size = Vector2(minf(500.0, width - 28.0), minf(440.0, height - 28.0))
	reward_panel.position = Vector2(margin + 20.0, height * 0.44)
	reward_panel.size = Vector2(maxf(260.0, width - margin * 2.0 - 40.0), 180.0)
	queue_redraw()

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _button(text: String, color: Color, background: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", REED)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_stylebox_override("normal", _style(background, LINE, 1, 8))
	button.add_theme_stylebox_override("hover", _style(Color("#312d24"), REED, 1, 8))
	button.add_theme_stylebox_override("pressed", _style(Color("#3c3527"), REED, 1, 8))
	button.add_theme_stylebox_override("disabled", _style(Color("#191719"), Color("#302c2b"), 1, 8))
	return button

func _style(background: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style
