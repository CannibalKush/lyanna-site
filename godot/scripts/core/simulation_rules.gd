class_name SimulationRules
extends RefCounted
## Pure rules for progression and effect math.
## These functions do not read or mutate scene nodes.

static func xp_needed(level: int) -> int:
	return 12 + level * 10

static func duration_multiplier(effects: Dictionary, system_id: String) -> float:
	var speed: float = float(effects.get("%s:speed" % system_id, 0.0))
	return 1.0 / (1.0 + speed)

static func xp_multiplier(effects: Dictionary, system_id: String) -> float:
	return 1.0 + float(effects.get("%s:xp" % system_id, 0.0))

static func yield_multiplier(effects: Dictionary, system_id: String) -> float:
	return 1.0 + float(effects.get("%s:yield" % system_id, 0.0))

static func critical_roll(effects: Dictionary, system_id: String, random_value: float) -> bool:
	var chance: float = float(effects.get("%s:critical" % system_id, 0.0))
	return random_value < chance

static func format_flow(activity: Dictionary) -> String:
	var outputs: Array[String] = []
	for raw_reward in activity.get("rewards", []):
		var reward: Dictionary = raw_reward
		outputs.append("+[%s]" % resource_icon(str(reward.currency)))
	var inputs: Array[String] = []
	for raw_cost in activity.get("costs", []):
		var cost: Dictionary = raw_cost
		inputs.append("-[%s]" % resource_icon(str(cost.currency)))
	return "%ds | %s | %s" % [int(activity.get("duration", 0.0)), ", ".join(outputs) if not outputs.is_empty() else "—", ", ".join(inputs) if not inputs.is_empty() else "—"]

static func resource_icon(currency: String) -> String:
	return {"reeds": "R", "water": "W", "clay": "C", "calm": "M", "focus": "F", "insight": "I", "silver": "S", "reputation": "P"}.get(currency, currency.substr(0, 1).to_upper())

static func resource_tooltip(activity: Dictionary) -> String:
	var parts: Array[String] = []
	for raw_cost in activity.get("costs", []):
		var cost: Dictionary = raw_cost
		parts.append("- %d %s" % [int(cost.amount), str(cost.currency).capitalize()])
	for raw_reward in activity.get("rewards", []):
		var reward: Dictionary = raw_reward
		parts.append("+ %d %s" % [int(reward.amount), str(reward.currency).capitalize()])
	return "\n".join(parts)
