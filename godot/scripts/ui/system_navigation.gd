class_name SystemNavigation
extends PanelContainer

signal system_selected(system_id: String)
var list: VBoxContainer

func build() -> void:
	add_theme_stylebox_override("panel", UiFactory.style(Color("#1b191b"), Color("#4b443c"), 1, 12))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	add_child(box)
	box.add_child(UiFactory.label("THE SYSTEMS", 11, Color("#d7c56d")))
	list = VBoxContainer.new()
	list.add_theme_constant_override("separation", 5)
	box.add_child(list)
	var hint := UiFactory.label("Unlock the next door by\nlearning the one before it.", 11, Color("#9c9587"))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(hint)

func update_systems(systems: Array, state: Dictionary, active_id: String) -> void:
	for child in list.get_children():
		child.queue_free()
	for raw_system in systems:
		var system: Dictionary = raw_system
		var unlocked: bool = _is_unlocked(system, state)
		var level: int = int(state.systems.get(system.id, {}).get("level", 1))
		var button := UiFactory.button("%s  %s  %s" % [system.get("glyph", "·"), system.name, "LV %02d" % level if unlocked else "LOCKED"], Color("#d7c56d") if unlocked else Color("#9c9587"), Color("#1b191b") if system.id != active_id else Color("#3b3527"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = not unlocked
		button.tooltip_text = system.description
		button.pressed.connect(system_selected.emit.bind(system.id))
		list.add_child(button)

func _is_unlocked(system: Dictionary, state: Dictionary) -> bool:
	if not system.has("requirements"):
		return true
	var requirement: Dictionary = system.requirements
	var required_state: Dictionary = state.systems.get(requirement.system, {})
	return int(required_state.get("level", 0)) >= int(requirement.level)
