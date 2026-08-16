extends Node
## Hoisted, serializable player state.
## Views and simulation code read this state; they do not own it.

const SAVE_PATH := "user://ego_incremental.json"
const VERSION := 1

var data: Dictionary = {}

func initialize(systems: Array) -> void:
	data = _fresh_state(systems)
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var loaded: Variant = JSON.parse_string(file.get_as_text())
			if loaded is Dictionary and int(loaded.get("version", 0)) == VERSION:
				data = loaded
	_ensure_default_unlocks(systems)

func reset(systems: Array) -> void:
	data = _fresh_state(systems)
	_ensure_default_unlocks(systems)
	save()

func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func _fresh_state(systems: Array) -> Dictionary:
	var fresh: Dictionary = {
		"version": VERSION,
		"day": 1,
		"overall_xp": 0,
		"currencies": {"reeds": 0, "water": 0, "clay": 0, "calm": 0, "focus": 8, "insight": 0, "silver": 0, "reputation": 0},
		"systems": {},
		"effects": {},
		"unlocked_activities": {"gathering:reeds": true, "gathering:water": true}
	}
	for raw_system in systems:
		var system: Dictionary = raw_system
		fresh.systems[system.id] = {"level": 1, "xp": 0, "actions": 0}
	return fresh

func _ensure_default_unlocks(systems: Array) -> void:
	if not data.has("unlocked_activities"):
		data["unlocked_activities"] = {}
	for raw_system in systems:
		var system: Dictionary = raw_system
		if not _is_system_unlocked(system, systems):
			continue
		var activities: Array = system.get("activities", []) as Array
		for index in activities.size():
			var activity: Dictionary = activities[index]
			var key := "%s:%s" % [system.id, activity.id]
			if not data.unlocked_activities.has(key):
				data.unlocked_activities[key] = index < 1 or system.id == "gathering" and index < 2

func _is_system_unlocked(system: Dictionary, systems: Array) -> bool:
	if not system.has("requirements"):
		return true
	var requirement: Dictionary = system.requirements
	var required_state: Dictionary = data.systems.get(requirement.system, {})
	return int(required_state.get("level", 0)) >= int(requirement.level)
