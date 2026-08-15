extends Control
## First playable Ego Incremental loop.
## Queue small jobs, watch them resolve, and improve the next day.

const BG := Color("#101512")
const PANEL := Color("#17221b")
const PANEL_ALT := Color("#1d2b21")
const LINE := Color("#304636")
const INK := Color("#e4ead8")
const MUTED := Color("#91a28f")
const ACCENT := Color("#d5e878")
const ACCENT_DARK := Color("#849b3a")
const DANGER := Color("#e69770")

const TASKS := {
	"wood": {"name": "Gather wood", "duration": 6.0, "reward": "wood", "amount": 3, "detail": "Safe work in the outer forest."},
	"herbs": {"name": "Gather herbs", "duration": 9.0, "reward": "herbs", "amount": 2, "detail": "Useful, but the path is longer."},
	"rest": {"name": "Rest at camp", "duration": 4.0, "reward": "energy", "amount": 25, "detail": "Recover energy before the next task."},
	"sell": {"name": "Visit the market", "duration": 5.0, "reward": "silver", "amount": 8, "detail": "Turn gathered goods into silver."}
}

var started := false
var day := 1
var energy := 100
var silver := 0
var wood := 0
var herbs := 0
var elapsed := 0.0
var task_progress := 0.0
var active_task: Dictionary = {}
var task_queue: Array[String] = []

var menu_layer: Control
var game_layer: Control
var task_list: VBoxContainer
var status_label: Label
var resource_label: Label
var day_label: Label
var active_label: Label
var active_detail: Label
var progress_bar: ProgressBar
var empty_label: Label
var task_buttons: Array[Button] = []

func _ready() -> void:
	set_process(true)
	_build_menu()
	_build_game()
	_show_menu()
	get_viewport().size_changed.connect(_layout)
	_layout()
	queue_redraw()

func _process(delta: float) -> void:
	if not started or active_task.is_empty():
		return
	elapsed += delta
	task_progress += delta
	var duration: float = float(active_task.get("duration", 1.0))
	progress_bar.value = min(100.0, task_progress / duration * 100.0)
	active_label.text = "%s  ·  %02d%%" % [active_task.get("name", "Working"), int(progress_bar.value)]
	if task_progress >= duration:
		_finish_task()
	_update_hud()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	var glow_center := Vector2(size.x * 0.78, size.y * 0.28)
	draw_circle(glow_center, min(size.x, size.y) * 0.24, Color(0.45, 0.62, 0.25, 0.06))
	draw_circle(glow_center, min(size.x, size.y) * 0.12, Color(0.75, 0.86, 0.36, 0.08))
	for index in 18:
		var x := fmod(float(index * 113) + elapsed * (2.0 + index % 3), max(1.0, size.x))
		var y := 80.0 + fmod(float(index * 61), max(1.0, size.y - 120.0))
		draw_circle(Vector2(x, y), 1.0 + float(index % 2), Color(0.75, 0.86, 0.36, 0.22))

func _build_menu() -> void:
	menu_layer = Control.new()
	menu_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_layer)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 330)
	panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 18))
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	content.add_theme_constant_override("margin_left", 34)
	content.add_theme_constant_override("margin_right", 34)
	content.add_theme_constant_override("margin_top", 28)
	content.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(content)

	var eyebrow := _label("EGO INCREMENTAL  /  PROTOTYPE", 12, ACCENT)
	content.add_child(eyebrow)
	var title := _label("Build a life\nthat keeps going.", 34, INK)
	content.add_child(title)
	var intro := _label("Queue work. Gather what you need.\nMake tomorrow easier than today.", 16, MUTED)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(intro)
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 18
	content.add_child(spacer)
	var start := _button("BEGIN DAY 01", ACCENT, BG)
	start.pressed.connect(_start_game)
	content.add_child(start)
	var note := _label("A tiny economic survival game about plans, pressure, and persistence.", 11, MUTED)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)

func _build_game() -> void:
	game_layer = Control.new()
	game_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(game_layer)

	var top := PanelContainer.new()
	top.name = "TopBar"
	top.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 0))
	game_layer.add_child(top)

	var top_content := HBoxContainer.new()
	top_content.add_theme_constant_override("separation", 20)
	top.add_child(top_content)
	day_label = _label("DAY 01", 14, ACCENT)
	top_content.add_child(day_label)
	var title := _label("EGO INCREMENTAL", 13, INK)
	top_content.add_child(title)
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_content.add_child(top_spacer)
	resource_label = _label("", 13, MUTED)
	top_content.add_child(resource_label)

	var tasks_panel := PanelContainer.new()
	tasks_panel.name = "TasksPanel"
	tasks_panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 14))
	game_layer.add_child(tasks_panel)
	var tasks_content := VBoxContainer.new()
	tasks_content.add_theme_constant_override("separation", 12)
	tasks_panel.add_child(tasks_content)
	tasks_content.add_child(_label("YOUR PLAN", 12, ACCENT))
	status_label = _label("Queue work for the day.", 14, INK)
	tasks_content.add_child(status_label)
	task_list = VBoxContainer.new()
	task_list.add_theme_constant_override("separation", 7)
	tasks_content.add_child(task_list)
	empty_label = _label("Nothing queued.\nChoose a task below.", 13, MUTED)
	task_list.add_child(empty_label)

	var world_panel := PanelContainer.new()
	world_panel.name = "WorldPanel"
	world_panel.add_theme_stylebox_override("panel", _style(PANEL_ALT, LINE, 1, 14))
	game_layer.add_child(world_panel)
	var world_content := VBoxContainer.new()
	world_content.add_theme_constant_override("separation", 10)
	world_panel.add_child(world_content)
	world_content.add_child(_label("THE OUTER FOREST", 12, ACCENT))
	active_label = _label("No task active", 25, INK)
	world_content.add_child(active_label)
	active_detail = _label("Your next decision waits below.", 14, MUTED)
	active_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_content.add_child(active_detail)
	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size.y = 18
	progress_bar.show_percentage = false
	progress_bar.add_theme_stylebox_override("background", _style(Color("#243329"), Color.TRANSPARENT, 0, 9))
	progress_bar.add_theme_stylebox_override("fill", _style(ACCENT_DARK, Color.TRANSPARENT, 0, 9))
	world_content.add_child(progress_bar)
	var hint := _label("The day moves while you plan.\nA good queue is a small promise to yourself.", 14, MUTED)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	world_content.add_child(hint)

	var actions := PanelContainer.new()
	actions.name = "ActionsPanel"
	actions.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 14))
	game_layer.add_child(actions)
	var actions_content := VBoxContainer.new()
	actions_content.add_theme_constant_override("separation", 8)
	actions.add_child(actions_content)
	actions_content.add_child(_label("ADD TO QUEUE", 11, ACCENT))
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	actions_content.add_child(buttons)
	for task_id in ["wood", "herbs", "rest", "sell"]:
		var task: Dictionary = TASKS[task_id]
		var button := _button("+ " + task.name, INK, BG)
		button.tooltip_text = task.detail
		button.pressed.connect(_queue_task.bind(task_id))
		buttons.add_child(button)
		task_buttons.append(button)

	var reset := _button("RESET DAY", MUTED, BG)
	reset.custom_minimum_size.x = 105
	reset.pressed.connect(_reset_day)
	buttons.add_child(reset)

func _start_game() -> void:
	started = true
	day = 1
	energy = 100
	silver = 0
	wood = 0
	herbs = 0
	task_queue = ["wood", "wood", "sell"]
	_show_game()
	_start_next_task()
	_update_hud()

func _queue_task(task_id: String) -> void:
	if task_queue.size() >= 6:
		status_label.text = "Your queue is full. Finish something first."
		return
	task_queue.append(task_id)
	_update_task_list()
	status_label.text = "%d task%s queued." % [task_queue.size(), "" if task_queue.size() == 1 else "s"]
	if active_task.is_empty():
		_start_next_task()

func _start_next_task() -> void:
	if task_queue.is_empty():
		active_task = {}
		active_label.text = "Day complete"
		active_detail.text = "Queue a new plan, then start the next day."
		progress_bar.value = 0.0
		_update_task_list()
		return
	var task_id: String = task_queue.pop_front()
	active_task = TASKS[task_id].duplicate()
	active_task["id"] = task_id
	task_progress = 0.0
	progress_bar.value = 0.0
	active_label.text = "%s  ·  00%%" % active_task.name
	active_detail.text = active_task.detail
	_update_task_list()

func _finish_task() -> void:
	var reward: String = active_task.reward
	var amount: int = int(active_task.amount)
	match reward:
		"wood": wood += amount
		"herbs": herbs += amount
		"energy": energy = min(100, energy + amount)
		"silver": silver += amount + wood + herbs
	energy = max(0, energy - 8)
	status_label.text = "%s complete. %s +%d." % [active_task.name, reward, amount]
	active_task = {}
	_start_next_task()
	_update_hud()

func _reset_day() -> void:
	day += 1
	energy = min(100, energy + 35)
	task_queue.clear()
	active_task = {}
	status_label.text = "Day %02d begins. Build a better plan." % day
	_start_next_task()
	_update_hud()

func _update_hud() -> void:
	if not resource_label:
		return
	day_label.text = "DAY %02d" % day
	resource_label.text = "ENERGY %03d   WOOD %02d   HERBS %02d   SILVER %03d" % [energy, wood, herbs, silver]
	_update_task_list()

func _update_task_list() -> void:
	if not task_list:
		return
	for child in task_list.get_children():
		if child != empty_label:
			child.queue_free()
	empty_label.visible = task_queue.is_empty() and active_task.is_empty()
	for index in task_queue.size():
		var task_id: String = task_queue[index]
		var task: Dictionary = TASKS[task_id]
		var row := PanelContainer.new()
		row.add_theme_stylebox_override("panel", _style(Color("#203025"), Color.TRANSPARENT, 0, 8))
		var label := _label("%02d   %s" % [index + 1, task.name], 14, INK)
		label.tooltip_text = task.detail
		row.add_child(label)
		task_list.add_child(row)

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
	var margin: float = 22.0 if width >= 760.0 else 12.0
	var top_height: float = 56.0
	var actions_height: float = 116.0 if width >= 760.0 else 170.0
	var content_top: float = top_height + margin
	var content_bottom: float = height - actions_height - margin
	var content_height: float = maxf(180.0, content_bottom - content_top)
	var task_width: float = minf(330.0, width * 0.31)
	var gap: float = 14.0
	var top := game_layer.get_node_or_null("TopBar") as Control
	var tasks := game_layer.get_node_or_null("TasksPanel") as Control
	var world := game_layer.get_node_or_null("WorldPanel") as Control
	var actions := game_layer.get_node_or_null("ActionsPanel") as Control
	if not top or not tasks or not world or not actions:
		return
	top.position = Vector2(0, 0)
	top.size = Vector2(width, top_height)
	for child in top.get_children():
		child.position = Vector2(margin, 0)
		child.size = Vector2(width - margin * 2.0, top_height)
	actions.position = Vector2(margin, height - actions_height)
	actions.size = Vector2(width - margin * 2.0, actions_height)
	if width >= 760.0:
		tasks.position = Vector2(margin, content_top)
		tasks.size = Vector2(task_width, content_height)
		world.position = Vector2(margin + task_width + gap, content_top)
		world.size = Vector2(width - margin * 2.0 - task_width - gap, content_height)
	else:
		var task_height: float = content_height * 0.46
		tasks.position = Vector2(margin, content_top)
		tasks.size = Vector2(width - margin * 2.0, task_height)
		world.position = Vector2(margin, content_top + task_height + gap)
		world.size = Vector2(width - margin * 2.0, content_height - task_height - gap)
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
	button.add_theme_color_override("font_hover_color", ACCENT)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_stylebox_override("normal", _style(background, LINE, 1, 8))
	button.add_theme_stylebox_override("hover", _style(Color("#26382a"), ACCENT_DARK, 1, 8))
	button.add_theme_stylebox_override("pressed", _style(Color("#33482d"), ACCENT, 1, 8))
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
