class_name RewardPopup
extends PanelContainer

signal choice_selected(choice: Dictionary)

var box: VBoxContainer

func build() -> void:
	visible = false
	add_theme_stylebox_override("panel", UiFactory.style(Color("#302b1d"), Color("#d7c56d"), 1, 12))
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	add_child(box)

func update_reward(reward: Dictionary) -> void:
	visible = not reward.is_empty()
	for child in box.get_children():
		child.queue_free()
	if reward.is_empty():
		return
	box.add_child(UiFactory.label("LEVEL %02d UNDERSTANDING" % int(reward.level), 13, Color("#d7c56d")))
	box.add_child(UiFactory.label("Choose what this system teaches you.", 12, Color("#9c9587")))
	for raw_choice in reward.choices:
		var choice: Dictionary = raw_choice
		var button := UiFactory.button("%s  /  %s" % [choice.label, choice.detail], Color("#eee8d4"), Color("#1b191b"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(choice_selected.emit.bind(choice))
		box.add_child(button)
