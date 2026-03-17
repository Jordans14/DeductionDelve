class_name ProfileIdentityState
extends RefCounted

static func default_public_id(display_name: String) -> String:
	var normalized := display_name.strip_edges().to_lower().replace(" ", "_")
	if normalized.is_empty():
		normalized = "delver"
	return "%s_%06d" % [normalized, posmod(hash(normalized), 1000000)]

static func build_public_identity_card(profile: Dictionary, display_name_func: Callable, heat_band: String) -> Dictionary:
	var account: Dictionary = Dictionary(profile.get("account", {}))
	var cosmetics: Dictionary = Dictionary(profile.get("cosmetics", {}))
	var equipped: Dictionary = Dictionary(cosmetics.get("equipped", {}))
	var title_id := str(equipped.get("title", ""))
	var banner_id := str(equipped.get("banner", ""))
	var legend_hint := _public_legend_hint(profile)
	var challenge_hint := _public_challenge_hint(profile)
	var crew_tag := _public_crew_tag(profile)
	var build_hint := _public_build_hint(profile)
	var presence_hint := _public_presence_hint(profile)
	return {
		"public_id": str(account.get("public_id", default_public_id(str(account.get("display_name", "Delver"))))),
		"display_name": str(account.get("display_name", "Delver")),
		"title_id": title_id,
		"title": str(display_name_func.call(title_id)),
		"banner_id": banner_id,
		"banner": str(display_name_func.call(banner_id)),
		"legend_hint": legend_hint,
		"challenge_hint": challenge_hint,
		"crew_tag": crew_tag,
		"build_hint": build_hint,
		"presence_hint": presence_hint,
		"heat_band": heat_band
	}

static func _public_legend_hint(profile: Dictionary) -> String:
	var players: Dictionary = Dictionary(Dictionary(profile.get("relationship_fabric", {})).get("players", {}))
	var account: Dictionary = Dictionary(profile.get("account", {}))
	var public_id := str(account.get("public_id", "")).strip_edges()
	var player_entry: Dictionary = Dictionary(players.get(public_id, {}))
	var title := str(player_entry.get("title", "")).strip_edges()
	if not title.is_empty():
		return title
	var public_read := str(player_entry.get("public_reputation", "")).strip_edges()
	if not public_read.is_empty():
		return public_read
	var status_burden := str(player_entry.get("status_burden", "")).strip_edges()
	if not status_burden.is_empty():
		return status_burden
	var persona: Dictionary = Dictionary(profile.get("persona_state", {}))
	var expectations := _string_array(persona.get("public_expectations", []))
	if not expectations.is_empty():
		return expectations[0]
	return ""

static func _public_challenge_hint(profile: Dictionary) -> String:
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var crawl_source := active_crawl
	if crawl_source.is_empty():
		var crawl_history := _dict_array(profile.get("crawl_history", []))
		if not crawl_history.is_empty():
			crawl_source = crawl_history[0]
	var hints: Array[String] = [
		str(crawl_source.get("promise_pressure", "")),
		str(crawl_source.get("public_challenge", "")),
		str(crawl_source.get("expectation_pressure", "")),
		str(_first_string(_string_array(crawl_source.get("doctrine_memory", [])), "")),
		str(_first_string(_string_array(crawl_source.get("governance_memory", [])), "")),
		str(_first_string(_string_array(crawl_source.get("model_memory", [])), "")),
		str(_first_string(_string_array(crawl_source.get("fault_memory", [])), "")),
		str(_first_string(_string_array(crawl_source.get("belief_pressure", [])), "")),
		str(_first_string(_string_array(crawl_source.get("memorial_residue", [])), ""))
	]
	for value in hints:
		var text: String = value.strip_edges()
		if not text.is_empty():
			return text
	return ""

static func _public_crew_tag(profile: Dictionary) -> String:
	var fabric: Dictionary = Dictionary(profile.get("relationship_fabric", {}))
	var recent_crews := _string_array(fabric.get("recent_crews", []))
	if recent_crews.is_empty():
		return ""
	var crews: Dictionary = Dictionary(fabric.get("crews", {}))
	var entry: Dictionary = Dictionary(crews.get(recent_crews[0], {}))
	var title := str(entry.get("title", "")).strip_edges()
	if not title.is_empty():
		return title
	var reputation := str(entry.get("public_reputation", "")).strip_edges()
	if not reputation.is_empty():
		return reputation
	var obligation := _first_string(_string_array(entry.get("obligations", [])), "")
	if not obligation.is_empty():
		return obligation
	var burden := str(entry.get("status_burden", "")).strip_edges()
	if not burden.is_empty():
		return burden
	return ""

static func _public_build_hint(profile: Dictionary) -> String:
	var last_run: Dictionary = Dictionary(profile.get("last_run", {}))
	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	var build_hint := str(frame.get("build_line", "")).strip_edges()
	if not build_hint.is_empty():
		return build_hint
	var doctrine_hint := str(frame.get("doctrine_line", "")).strip_edges()
	if not doctrine_hint.is_empty():
		return doctrine_hint
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var build_memory := _string_array(active_crawl.get("build_memory", []))
	if not build_memory.is_empty():
		return build_memory[0]
	var stability_memory := _string_array(active_crawl.get("stability_memory", []))
	if not stability_memory.is_empty():
		return stability_memory[0]
	return ""

static func _public_presence_hint(profile: Dictionary) -> String:
	var last_run: Dictionary = Dictionary(profile.get("last_run", {}))
	var frame: Dictionary = Dictionary(last_run.get("frame", {}))
	var presence_hint := str(frame.get("inhabitant_line", "")).strip_edges()
	if not presence_hint.is_empty():
		return presence_hint
	var governance_hint := str(frame.get("governance_line", "")).strip_edges()
	if not governance_hint.is_empty():
		return governance_hint
	var active_crawl: Dictionary = Dictionary(profile.get("active_crawl", {}))
	var presence_memory := _string_array(active_crawl.get("inhabitant_memory", []))
	if not presence_memory.is_empty():
		return presence_memory[0]
	var protocol_memory := _string_array(active_crawl.get("protocol_memory", []))
	if not protocol_memory.is_empty():
		return protocol_memory[0]
	return ""

static func _first_string(values: Array[String], fallback: String) -> String:
	for value in values:
		var text := str(value).strip_edges()
		if not text.is_empty():
			return text
	return fallback

static func _string_array(values: Variant) -> Array[String]:
	var result: Array[String] = []
	if values is Array:
		for value in values:
			var text: String = str(value).strip_edges()
			if not text.is_empty() and not result.has(text):
				result.append(text)
	return result

static func _dict_array(values: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if values is Array:
		for value in values:
			if value is Dictionary:
				result.append(Dictionary(value))
	return result
