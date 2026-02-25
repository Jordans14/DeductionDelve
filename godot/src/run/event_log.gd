extends Node

signal timeline_event_added(event: Dictionary)

var events: Array = []

func clear() -> void:
	events.clear()

func add_event(event: Dictionary) -> void:
	events.append(event)
	events.sort_custom(Callable(self, "_event_less"))
	emit_signal("timeline_event_added", event)

func get_recent(limit: int = 8) -> Array:
	if events.size() <= limit:
		return events.duplicate(true)
	return events.slice(events.size() - limit, events.size())

func _event_less(a: Dictionary, b: Dictionary) -> bool:
	var a_tick := int(a.get("tick", -1))
	var b_tick := int(b.get("tick", -1))
	if a_tick != b_tick:
		return a_tick < b_tick
	var a_id := int(a.get("event_id", -1))
	var b_id := int(b.get("event_id", -1))
	return a_id < b_id
