class_name ContentDatabase
extends RefCounted
## Loads declarative game content without coupling it to the view.

static func load_systems(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return []
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed.get("systems", []) as Array
	return []
