extends Node

signal timeline_event_added(event: Dictionary)

var events: Array = []

func clear() -> void:
	events.clear()

func add_event(event: Dictionary) -> void:
	events.append(event)
	events.sort_custom(Callable(self, "_event_less"))
	print("TIMELINE_EVENT tick=%d event_id=%d type=%s room_slot=%d actor=%d visibility=%s" % [
		int(event.get("tick", -1)),
		int(event.get("event_id", -1)),
		str(event.get("event_type", "unknown")),
		int(event.get("room_slot", -1)),
		int(event.get("actor_peer_id", -1)),
		str(event.get("visibility", "public"))
	])
	emit_signal("timeline_event_added", event)

func get_recent(limit: int = 8) -> Array:
	if events.size() <= limit:
		return events.duplicate(true)
	return events.slice(events.size() - limit, events.size())

func get_recent_public(limit: int = 8) -> Array:
	var public_events: Array = []
	for event in events:
		var event_dict: Dictionary = event
		if str(event_dict.get("visibility", "public")) == "public":
			public_events.append(event_dict.duplicate(true))
	if public_events.size() <= limit:
		return public_events
	return public_events.slice(public_events.size() - limit, public_events.size())

func get_recent_private(limit: int = 8) -> Array:
	var private_events: Array = []
	for event in events:
		var event_dict: Dictionary = event
		if str(event_dict.get("visibility", "")) == "private":
			private_events.append(event_dict.duplicate(true))
	if private_events.size() <= limit:
		return private_events
	return private_events.slice(private_events.size() - limit, private_events.size())

func get_recent_private_for(peer_id: int, limit: int = 8) -> Array:
	var private_events: Array = []
	for event in events:
		var event_dict: Dictionary = event
		if str(event_dict.get("visibility", "")) != "private":
			continue
		if int(event_dict.get("target_peer_id", -1)) != peer_id:
			continue
		private_events.append(event_dict.duplicate(true))
	if private_events.size() <= limit:
		return private_events
	return private_events.slice(private_events.size() - limit, private_events.size())

func _event_less(a: Dictionary, b: Dictionary) -> bool:
	var a_tick := int(a.get("tick", -1))
	var b_tick := int(b.get("tick", -1))
	if a_tick != b_tick:
		return a_tick < b_tick
	var a_id := int(a.get("event_id", -1))
	var b_id := int(b.get("event_id", -1))
	return a_id < b_id
