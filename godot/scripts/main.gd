extends Node2D

const BACKGROUND := Color("#171a18")
const INK := Color("#d9dfcf")
const MUTED := Color("#879184")
const ACCENT := Color("#c9d86b")
const HILL_BACK := Color("#27372e")
const HILL_FRONT := Color("#324a3a")

var elapsed := 0.0
var light_collected := 0
var status_label: Label

func _ready() -> void:
	get_viewport().size_changed.connect(queue_redraw)
	status_label = Label.new()
	status_label.position = Vector2(32.0, 28.0)
	status_label.add_theme_color_override("font_color", INK)
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(status_label)
	_update_status()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_collect_light()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_collect_light()

func _collect_light() -> void:
	light_collected += 1
	_update_status()
	queue_redraw()

func _update_status() -> void:
	if status_label:
		status_label.text = "POCKET FIELD  /  DAY 001\n\nLIGHT  %02d\n\n[ click or space ] gather a little light" % light_collected

func _draw() -> void:
	var viewport_size := get_viewport_rect().size
	var center := viewport_size * 0.5

	draw_rect(Rect2(Vector2.ZERO, viewport_size), BACKGROUND)
	draw_circle(Vector2(viewport_size.x * 0.76, viewport_size.y * 0.24), 58.0, Color("#d5dd9a"))
	draw_circle(Vector2(viewport_size.x * 0.76, viewport_size.y * 0.24), 88.0, Color(0.78, 0.84, 0.42, 0.06))

	var back_hill := PackedVector2Array([
		Vector2(0.0, viewport_size.y * 0.64),
		Vector2(viewport_size.x * 0.22, viewport_size.y * 0.50),
		Vector2(viewport_size.x * 0.47, viewport_size.y * 0.59),
		Vector2(viewport_size.x * 0.73, viewport_size.y * 0.45),
		Vector2(viewport_size.x, viewport_size.y * 0.57),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0.0, viewport_size.y),
	])
	draw_colored_polygon(back_hill, HILL_BACK)

	var front_hill := PackedVector2Array([
		Vector2(0.0, viewport_size.y * 0.78),
		Vector2(viewport_size.x * 0.24, viewport_size.y * 0.67),
		Vector2(viewport_size.x * 0.54, viewport_size.y * 0.72),
		Vector2(viewport_size.x * 0.82, viewport_size.y * 0.61),
		Vector2(viewport_size.x, viewport_size.y * 0.72),
		Vector2(viewport_size.x, viewport_size.y),
		Vector2(0.0, viewport_size.y),
	])
	draw_colored_polygon(front_hill, HILL_FRONT)

	for index in 12:
		var x := fmod(float(index * 157) + elapsed * (4.0 + index), viewport_size.x)
		var y := 70.0 + fmod(float(index * 83), viewport_size.y * 0.42)
		draw_circle(Vector2(x, y), 1.5 + float(index % 3), Color(0.78, 0.84, 0.42, 0.35))

	var player_position := center + Vector2(0.0, viewport_size.y * 0.13)
	var breathe := sin(elapsed * 2.0) * 3.0
	draw_circle(player_position, 22.0 + breathe, Color(0.79, 0.85, 0.42, 0.10))
	draw_circle(player_position, 12.0, ACCENT)
	draw_circle(player_position + Vector2(-4.0, -3.0), 3.0, INK)
	draw_arc(player_position, 34.0, 0.0, TAU, 48, Color(0.79, 0.85, 0.42, 0.28), 1.0)

	draw_string(ThemeDB.fallback_font, Vector2(32.0, viewport_size.y - 30.0), "GODOT 4  /  2D SKELETON", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
