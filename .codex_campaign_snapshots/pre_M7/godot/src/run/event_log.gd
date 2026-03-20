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

func add_mutation_event(mutation_event: Dictionary) -> void:
	var visibility := str(mutation_event.get("visibility", "private"))
	var timeline_event := {
		"tick": int(mutation_event.get("tick", -1)),
		"event_id": int(mutation_event.get("timeline_event_id", mutation_event.get("ordering_index", -1))),
		"event_type": "constitution_mutation",
		"room_slot": int(Dictionary(mutation_event.get("public_meta", {})).get("room_slot", -1)),
		"actor_peer_id": int(mutation_event.get("actor_peer_id", -1)),
		"visibility": visibility,
		"meta": {
			"mutation_id": str(mutation_event.get("mutation_id", "")),
			"trigger_type": str(mutation_event.get("trigger_type", "")),
			"domain": str(mutation_event.get("domain", "")),
			"public_meta": Dictionary(mutation_event.get("public_meta", {})).duplicate(true)
		}
	}
	add_event(timeline_event)

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

func canonical_events(visibility_filter: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event_raw in events:
		var event := Dictionary(event_raw).duplicate(true)
		if not visibility_filter.strip_edges().is_empty() and str(event.get("visibility", "")).strip_edges() != visibility_filter:
			continue
		result.append(event)
	result.sort_custom(Callable(self, "_event_less"))
	return result

func event_id_range(visibility_filter: String = "") -> Dictionary:
	var ordered := canonical_events(visibility_filter)
	if ordered.is_empty():
		return {
			"min_event_id": -1,
			"max_event_id": -1,
			"event_count": 0
		}
	return {
		"min_event_id": int(Dictionary(ordered[0]).get("event_id", -1)),
		"max_event_id": int(Dictionary(ordered[ordered.size() - 1]).get("event_id", -1)),
		"event_count": ordered.size()
	}

func timeline_digest(visibility_filter: String = "") -> String:
	return _canonical_string(canonical_events(visibility_filter)).md5_text()

func encounter_events(limit: int = 0) -> Array:
	var result: Array = []
	for event_raw in events:
		var event := Dictionary(event_raw).duplicate(true)
		if str(event.get("event_type", "")).strip_edges() != "constitution_mutation":
			continue
		var meta: Dictionary = Dictionary(event.get("meta", {}))
		if str(meta.get("trigger_type", "")).strip_edges() != "species_escalation":
			continue
		result.append(event)
	if limit > 0 and result.size() > limit:
		return result.slice(result.size() - limit, result.size())
	return result

func _event_less(a: Dictionary, b: Dictionary) -> bool:
	var a_tick := int(a.get("tick", -1))
	var b_tick := int(b.get("tick", -1))
	if a_tick != b_tick:
		return a_tick < b_tick
	var a_id := int(a.get("event_id", -1))
	var b_id := int(b.get("event_id", -1))
	return a_id < b_id

func _canonical_string(value: Variant) -> String:
	match typeof(value):
		TYPE_DICTIONARY:
			var dict: Dictionary = value
			var key_texts: Array[String] = []
			var key_lookup: Dictionary = {}
			for key in dict.keys():
				var text := str(key)
				key_texts.append(text)
				key_lookup[text] = key
			key_texts.sort()
			var segments: Array[String] = []
			for key_text in key_texts:
				segments.append("%s:%s" % [key_text, _canonical_string(dict.get(key_lookup[key_text]))])
			return "{%s}" % ",".join(segments)
		TYPE_ARRAY:
			var segments: Array[String] = []
			for item in value:
				segments.append(_canonical_string(item))
			return "[%s]" % ",".join(segments)
		TYPE_STRING:
			return JSON.stringify(value)
		_:
			return str(value)
